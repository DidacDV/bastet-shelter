import pytest
from unittest.mock import MagicMock, patch
from datetime import date, datetime, timedelta

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.models.adoption.adoption_steps.adoption_step import StepStatusEnum, StepTypeEnum
from app.models.adoption.adoption_steps.adoption_form import AdoptionForm
from app.models.adoption.adoption_steps.animal_pickup import AnimalPickup
from app.models.adoption.adoption_steps.contract import Contract
from app.models.adoption.adoption_steps.interview import Interview
from app.models.adoption.adoption_steps.shelter_visit import ShelterVisit
from app.schemas.adoption_schema.adoption_schema import ScheduledDateUpdate, NotesUpdate
from app.schemas.adoption_schema.adoption_step_schema import AdvanceStepRequest
from app.services.adoption_steps_service import AdoptionStepsService


@pytest.fixture
def service():
    db = MagicMock()
    s = AdoptionStepsService(db)
    s.step_repo = MagicMock()
    s.process_repo = MagicMock()
    return s


def test_get_current_step_or_raise_success(service):
    mock_step = MagicMock(spec=Interview)
    service.step_repo.get_current_step.return_value = mock_step

    result = service._get_current_step_or_raise(1)
    assert result == mock_step


def test_get_current_step_or_raise_not_found(service):
    service.step_repo.get_current_step.return_value = None
    with pytest.raises(NotFoundError):
        service._get_current_step_or_raise(1)


def test_check_has_scheduled_date_passed_no_date(service):
    with pytest.raises(BusinessLogicError) as exc:
        service._check_has_scheduled_date_passed(None, "Interview")
    assert "no scheduled date" in str(exc.value)


def test_check_has_scheduled_date_passed_not_yet(service):
    future_date = datetime.now() + timedelta(days=1)
    with pytest.raises(BusinessLogicError) as exc:
        service._check_has_scheduled_date_passed(future_date, "Interview")
    assert "has not passed yet" in str(exc.value)


def test_advance_form(service):
    step = MagicMock(spec=AdoptionForm)
    request = AdvanceStepRequest(notes="Looks good")

    service._advance_form(step, request)
    assert step.accepted is True
    assert step.status == StepStatusEnum.COMPLETED
    assert step.finish_date == date.today()
    assert step.notes == "Looks good"


def test_advance_interview(service):
    past_date = datetime.now() - timedelta(days=1)
    step = MagicMock(spec=Interview)
    step.scheduled_at = past_date
    request = AdvanceStepRequest(notes="Great call")

    service._advance_interview(step, request)
    assert step.status == StepStatusEnum.COMPLETED
    assert step.finish_date == date.today()
    assert step.notes == "Great call"


@patch("app.services.adoption_steps_service.cloudinary_uploader.upload")
@patch("app.services.adoption_steps_service.pdf_service.generate_contract_pdf")
def test_generate_contract(mock_pdf_gen, mock_upload, service):
    process = MagicMock()
    process.animal.name = "Luna"
    process.animal.refuge.shelter_id = 5
    process.adoptant.name = "Alice"
    service.process_repo.get_by_id.return_value = process

    contract_step = MagicMock(spec=Contract)
    service.step_repo.get_steps_for_process.return_value = [contract_step]

    mock_pdf_gen.return_value = b"pdfbytes"
    mock_upload.return_value = {"secure_url": "https://url.pdf", "public_id": "pid"}

    service._generate_contract(1)
    assert contract_step.contract_url == "https://url.pdf"
    assert contract_step.cloudinary_public_id == "pid"
    assert contract_step.generation_date == date.today()
    service.db.commit.assert_called_once()


def test_advance_shelter_visit(service):
    past_date = datetime.now() - timedelta(days=1)
    step = MagicMock(spec=ShelterVisit)
    step.scheduled_at = past_date
    step.adoption_process_id = 1
    request = AdvanceStepRequest(notes="Visited")

    service._generate_contract = MagicMock()
    service._advance_shelter_visit(step, request)

    assert step.status == StepStatusEnum.COMPLETED
    assert step.finish_date == date.today()
    assert step.notes == "Visited"
    service._generate_contract.assert_called_once_with(process_id=1)


def test_advance_contract_not_signed(service):
    step = MagicMock(spec=Contract)
    step.signed_by_adoptant = False
    step.signed_by_shelter = True
    request = AdvanceStepRequest(notes="Sign")

    with pytest.raises(BusinessLogicError):
        service._advance_contract(step, request)


def test_advance_contract_success(service):
    step = MagicMock(spec=Contract)
    step.signed_by_adoptant = True
    step.signed_by_shelter = True
    request = AdvanceStepRequest(notes="Signed")

    service._advance_contract(step, request)
    assert step.status == StepStatusEnum.COMPLETED
    assert step.notes == "Signed"


def test_advance_animal_pickup(service):
    past_date = datetime.now() - timedelta(days=1)
    step = MagicMock(spec=AnimalPickup)
    step.scheduled_at = past_date
    request = AdvanceStepRequest(notes="Picked up")

    service._advance_animal_pickup(step, request)
    assert step.status == StepStatusEnum.COMPLETED
    assert isinstance(step.actual_pickup_at, datetime)
    assert step.notes == "Picked up"


def test_advance_current_step(service):
    mock_step = MagicMock(spec=AdoptionForm)
    mock_step.type = StepTypeEnum.FORM
    service._get_current_step_or_raise = MagicMock(return_value=mock_step)
    service._advance_form = MagicMock()

    request = AdvanceStepRequest(notes="Ok")
    service.advance_current_step(1, request)

    service._advance_form.assert_called_once_with(mock_step, request)
    service.db.commit.assert_called_once()
    service.db.refresh.assert_called_once_with(mock_step)


def test_skip_step_forbidden(service):
    mock_step = MagicMock(spec=AdoptionForm)
    mock_step.type = StepTypeEnum.FORM
    service._get_current_step_or_raise = MagicMock(return_value=mock_step)

    with pytest.raises(BusinessLogicError):
        service.skip_step(1)


def test_skip_step_success(service):
    mock_step = MagicMock(spec=Interview)
    mock_step.type = StepTypeEnum.INTERVIEW
    service._get_current_step_or_raise = MagicMock(return_value=mock_step)

    service.skip_step(1)
    assert mock_step.status == StepStatusEnum.SKIPPED
    assert mock_step.finish_date == date.today()
    service.db.commit.assert_called_once()


def test_has_pending_steps(service):
    service.step_repo.get_current_step.return_value = MagicMock()
    assert service.has_pending_steps(1) is True

    service.step_repo.get_current_step.return_value = None
    assert service.has_pending_steps(1) is False


def test_get_form_details_success(service):
    form = MagicMock(spec=AdoptionForm)
    service.step_repo.get_steps_for_process.return_value = [form]
    assert service.get_form_details(1) == form


def test_get_form_details_not_found(service):
    service.step_repo.get_steps_for_process.return_value = []
    with pytest.raises(NotFoundError):
        service.get_form_details(1)


@patch("app.services.adoption_steps_service.step_to_detail_response")
def test_set_scheduled_date_success(mock_mapper, service):
    step = MagicMock()
    step.type = StepTypeEnum.INTERVIEW
    step.status = StepStatusEnum.PENDING
    service.step_repo.get_steps_for_process.return_value = [step]

    current_step = MagicMock()
    current_step.type = StepTypeEnum.INTERVIEW
    service._get_current_step_or_raise = MagicMock(return_value=current_step)

    target_time = datetime.now()
    service._set_scheduled_date(1, StepTypeEnum.INTERVIEW, target_time)

    assert step.scheduled_at == target_time
    service.db.commit.assert_called_once()


def test_set_scheduled_date_wrong_current_step(service):
    current_step = MagicMock()
    current_step.type = StepTypeEnum.FORM
    service._get_current_step_or_raise = MagicMock(return_value=current_step)

    with pytest.raises(BusinessLogicError):
        service._set_scheduled_date(1, StepTypeEnum.INTERVIEW, datetime.now())


@patch("app.services.adoption_steps_service.step_to_detail_response")
def test_set_interview_scheduled_date(mock_mapper, service):
    service._set_scheduled_date = MagicMock()
    dt = datetime.now()
    service.set_interview_scheduled_date(1, ScheduledDateUpdate(scheduled_at=dt))
    service._set_scheduled_date.assert_called_once_with(1, StepTypeEnum.INTERVIEW, dt)


@patch("app.services.adoption_steps_service.step_to_detail_response")
def test_set_shelter_visit_scheduled_date(mock_mapper, service):
    service._set_scheduled_date = MagicMock()
    dt = datetime.now()
    service.set_shelter_visit_scheduled_date(1, ScheduledDateUpdate(scheduled_at=dt))
    service._set_scheduled_date.assert_called_once_with(1, StepTypeEnum.SHELTER_VISIT, dt)


@patch("app.services.adoption_steps_service.step_to_detail_response")
def test_set_animal_pickup_scheduled_date(mock_mapper, service):
    service._set_scheduled_date = MagicMock()
    dt = datetime.now()
    service.set_animal_pickup_scheduled_date(1, ScheduledDateUpdate(scheduled_at=dt))
    service._set_scheduled_date.assert_called_once_with(1, StepTypeEnum.ANIMAL_PICKUP, dt)


@patch("app.services.adoption_steps_service.step_to_detail_response")
def test_set_animal_pickup_actual_date_success(mock_mapper, service):
    step = MagicMock(spec=AnimalPickup)
    step.adoption_process_id = 1
    step.scheduled_at = datetime.now()
    service.step_repo.get_by_id.return_value = step

    dt = datetime.now()
    service.set_animal_pickup_actual_date(1, 2, ScheduledDateUpdate(scheduled_at=dt))

    assert step.actual_pickup_at == dt
    service.db.commit.assert_called_once()


def test_set_animal_pickup_actual_date_wrong_process(service):
    step = MagicMock(spec=AnimalPickup)
    step.adoption_process_id = 99
    service.step_repo.get_by_id.return_value = step

    with pytest.raises(BusinessLogicError):
        service.set_animal_pickup_actual_date(1, 2, ScheduledDateUpdate(scheduled_at=datetime.now()))


@patch("app.services.adoption_steps_service.step_to_detail_response")
def test_add_notes(mock_mapper, service):
    step = MagicMock()
    step.adoption_process_id = 1
    service.step_repo.get_by_id.return_value = step

    service.add_notes(1, 2, NotesUpdate(notes="New note"))
    assert step.notes == "New note"
    service.db.commit.assert_called_once()


def test_get_contract_step_or_raise_not_found(service):
    service.step_repo.get_steps_for_process.return_value = []
    with pytest.raises(NotFoundError):
        service._get_contract_step_or_raise(1)


@patch("app.services.adoption_steps_service.step_to_detail_response")
def test_update_adoptant_signature_success(mock_mapper, service):
    process = MagicMock()
    process.adoptant_id = 10
    service.process_repo.get_by_id.return_value = process

    contract = MagicMock(spec=Contract)
    service.step_repo.get_steps_for_process.return_value = [contract]

    service.update_adoptant_signature(1, 10)
    assert contract.signed_by_adoptant is True
    service.db.commit.assert_called_once()


def test_update_adoptant_signature_unauthorized(service):
    process = MagicMock()
    process.adoptant_id = 10
    service.process_repo.get_by_id.return_value = process

    with pytest.raises(BusinessLogicError):
        service.update_adoptant_signature(1, 99)


@patch("app.services.adoption_steps_service.step_to_detail_response")
def test_update_shelter_signature(mock_mapper, service):
    contract = MagicMock(spec=Contract)
    contract.signed_by_shelter = False
    service.step_repo.get_steps_for_process.return_value = [contract]

    service.update_shelter_signature(1)
    assert contract.signed_by_shelter is True
    service.db.commit.assert_called_once()