import pytest
from unittest.mock import MagicMock

from app.core.exceptions import AuthorizationError, BusinessLogicError, NotFoundError
from app.models.medical.medicine import Medicine
from app.services.medical_service import MedicalService


@pytest.fixture
def service():
    db = MagicMock()
    s = MedicalService(db)
    s.medicine_repo = MagicMock()
    return s


def test_delete_medicine_success(service):
    medicine_id = 1
    shelter_id = 1
    mock_medicine = MagicMock(spec=Medicine)
    mock_medicine.shelter_id = shelter_id

    service.medicine_repo.get_by_id.return_value = mock_medicine
    service.medicine_repo.is_used_in_active_treatment.return_value = False

    service.delete_medicine(medicine_id, shelter_id)

    service.medicine_repo.delete.assert_called_once_with(service.db, medicine_id)


def test_delete_medicine_not_found(service):
    service.medicine_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError):
        service.delete_medicine(1, 1)


def test_delete_medicine_wrong_shelter(service):
    mock_medicine = MagicMock(spec=Medicine)
    mock_medicine.shelter_id = 2
    service.medicine_repo.get_by_id.return_value = mock_medicine

    with pytest.raises(AuthorizationError):
        service.delete_medicine(1, 1)


def test_delete_medicine_used_in_active_treatment(service):
    mock_medicine = MagicMock(spec=Medicine)
    mock_medicine.shelter_id = 1
    service.medicine_repo.get_by_id.return_value = mock_medicine
    service.medicine_repo.is_used_in_active_treatment.return_value = True

    with pytest.raises(BusinessLogicError) as excinfo:
        service.delete_medicine(1, 1)

    assert "active" in excinfo.value.message.lower()
    assert "treatment" in excinfo.value.message.lower()
    service.medicine_repo.delete.assert_not_called()
