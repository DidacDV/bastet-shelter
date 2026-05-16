import pytest
from unittest.mock import MagicMock, patch
from datetime import datetime, timezone, timedelta

from app.models.medical.medical_treatment import MedicineStatusEnum, MedicineFrequencyEnum
from app.jobs.treatment_reset_job import reset_treatments

def make_mock_treatment(frequency, days_since_update, status=MedicineStatusEnum.GIVEN):
    treatment = MagicMock()
    treatment.status = status
    treatment.frequency = frequency
    treatment.status_updated_at = datetime.now(timezone.utc) - timedelta(days=days_since_update)
    return treatment

@pytest.fixture
def mock_db():
    with patch("app.jobs.treatment_reset_job.SessionLocal") as mock_session:
        db = MagicMock()
        mock_session.return_value = db
        yield db

def test_daily_treatment_resets_after_1_day(mock_db):
    treatment = make_mock_treatment(MedicineFrequencyEnum.DAILY, days_since_update=1)
    mock_db.query.return_value.filter.return_value.all.return_value = [treatment]

    reset_treatments()

    assert treatment.status == MedicineStatusEnum.PENDING
    assert treatment.status_last_updated_by_id is None
    mock_db.commit.assert_called_once()

def test_weekly_treatment_resets_after_7_days(mock_db):
    treatment = make_mock_treatment(MedicineFrequencyEnum.WEEKLY, days_since_update=7)
    mock_db.query.return_value.filter.return_value.all.return_value = [treatment]

    reset_treatments()

    assert treatment.status == MedicineStatusEnum.PENDING

def test_monthly_treatment_resets_after_30_days(mock_db):
    treatment = make_mock_treatment(MedicineFrequencyEnum.MONTHLY, days_since_update=30)
    mock_db.query.return_value.filter.return_value.all.return_value = [treatment]

    reset_treatments()

    assert treatment.status == MedicineStatusEnum.PENDING

def test_daily_treatment_not_reset_before_1_day(mock_db):
    treatment = make_mock_treatment(MedicineFrequencyEnum.DAILY, days_since_update=0)
    mock_db.query.return_value.filter.return_value.all.return_value = [treatment]

    reset_treatments()

    assert treatment.status == MedicineStatusEnum.GIVEN

def test_weekly_treatment_not_reset_before_7_days(mock_db):
    treatment = make_mock_treatment(MedicineFrequencyEnum.WEEKLY, days_since_update=5)
    mock_db.query.return_value.filter.return_value.all.return_value = [treatment]

    reset_treatments()

    assert treatment.status == MedicineStatusEnum.GIVEN

def test_as_needed_treatment_never_resets(mock_db):
    treatment = make_mock_treatment(MedicineFrequencyEnum.AS_NEEDED, days_since_update=999)
    mock_db.query.return_value.filter.return_value.all.return_value = [treatment]

    reset_treatments()

    assert treatment.status == MedicineStatusEnum.GIVEN

def test_pending_treatments_are_skipped(mock_db):
    mock_db.query.return_value.filter.return_value.all.return_value = []

    reset_treatments()

    mock_db.commit.assert_called_once()

def test_rollback_on_exception(mock_db):
    mock_db.query.return_value.filter.return_value.all.side_effect = Exception("DB error")

    with pytest.raises(Exception, match="DB error"):
        reset_treatments()

    mock_db.rollback.assert_called_once()
    mock_db.commit.assert_not_called()

def test_db_session_always_closed(mock_db):
    mock_db.query.return_value.filter.return_value.all.return_value = []

    reset_treatments()

    mock_db.close.assert_called_once()

def test_db_session_closed_even_on_exception(mock_db):
    mock_db.query.return_value.filter.return_value.all.side_effect = Exception("DB error")

    with pytest.raises(Exception):
        reset_treatments()

    mock_db.close.assert_called_once()