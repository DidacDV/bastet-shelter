import pytest
from unittest.mock import MagicMock, patch
from datetime import date

from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError
from app.services.adoption_process_service import AdoptionProcessService
from app.models.adoption.adoption_process import AdoptionProcessStatusEnum
from app.models.adoption.adoption_steps.adoption_step import StepStatusEnum, StepTypeEnum
from app.models.adoption.adoption_steps.contract import Contract
from app.schemas.adoption_schema.adoption_form_schema import AdoptionFormSubmit

def _mock_animal(**overrides):
    animal = MagicMock()
    animal.id = overrides.get("id", 100)
    animal.name = overrides.get("name", "Fluffy")
    animal.in_adoption = overrides.get("in_adoption", True)
    animal.refuge_id = overrides.get("refuge_id", 10)
    animal.refuge = MagicMock()
    animal.refuge.shelter_id = overrides.get("shelter_id", 1)
    animal.refuge.shelter = MagicMock()
    animal.refuge.shelter.name = "Test Shelter"
    animal.refuge.shelter.email = "shelter@test.com"
    return animal


def _mock_adoptant(**overrides):
    adoptant = MagicMock()
    adoptant.id = overrides.get("id", 200)
    adoptant.name = overrides.get("name", "John Doe")
    adoptant.email = overrides.get("email", "john@example.com")
    return adoptant


def _mock_process(**overrides):
    process = MagicMock()
    process.id = overrides.get("id", 300)
    process.animal_id = overrides.get("animal_id", 100)
    process.adoptant_id = overrides.get("adoptant_id", 200)
    process.status = overrides.get("status", AdoptionProcessStatusEnum.ACTIVE)
    process.start_date = date(2026, 1, 1)

    process.animal = overrides.get("animal", _mock_animal())
    process.adoptant = overrides.get("adoptant", _mock_adoptant())
    return process


def _mock_contract_step(**overrides):
    step = MagicMock(spec=Contract)
    step.id = overrides.get("id", 400)
    step.type = StepTypeEnum.CONTRACT
    step.status = overrides.get("status", StepStatusEnum.PENDING)
    return step

@pytest.fixture
def service():
    db = MagicMock()
    s = AdoptionProcessService(db)
    s.adoptant_repo = MagicMock()
    s.process_repo = MagicMock()
    s.step_repo = MagicMock()
    s.animal_repo = MagicMock()
    return s

def test_get_process_or_raise_success(service):
    mock_p = _mock_process()
    service.process_repo.get_by_id.return_value = mock_p
    assert service._get_process_or_raise(300) == mock_p


def test_get_process_or_raise_not_found(service):
    service.process_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError, match="Adoption process not found"):
        service._get_process_or_raise(999)


def test_check_is_process_active_not_active(service):
    mock_p = _mock_process(status=AdoptionProcessStatusEnum.COMPLETED)
    service.process_repo.get_by_id.return_value = mock_p
    with pytest.raises(BusinessLogicError, match="Adoption process is not active"):
        service.check_is_process_active(300)


def test_check_belongs_to_shelter_unauthorized(service):
    mock_p = _mock_process()
    mock_animal = _mock_animal(shelter_id=2)
    service.animal_repo.get_by_id.return_value = mock_animal

    mock_refuge = MagicMock()
    mock_refuge.shelter_id = 2
    service.db.query().filter().first.return_value = mock_refuge

    with pytest.raises(AuthorizationError, match="Not authorized to view this adoption process"):
        service._check_belongs_to_shelter(mock_p, shelter_id=1)


@patch("app.services.adoption_process_service.send_email")
@patch("app.services.adoption_process_service.process_to_response")
def test_start_adoption_success(mock_process_to_response, mock_send_email, service):
    animal_id = 100
    mock_animal = _mock_animal(id=animal_id, in_adoption=True)
    mock_adoptant = _mock_adoptant()

    service.animal_repo.get_by_id.return_value = mock_animal
    service.process_repo.get_active_process_for_animal.return_value = None
    service.adoptant_repo.get_or_create.return_value = mock_adoptant

    form_data = AdoptionFormSubmit(
        first_name="John",
        last_name="Doe",
        address="123 Street",
        phone_number="123456789",
    )
    mock_bg_tasks = MagicMock()

    mock_process_to_response.return_value = "ProcessResponse"

    result = service.start_adoption(
        animal_id=animal_id,
        adoptant_email="john@example.com",
        adoptant_name="John Doe",
        form_data=form_data,
        background_tasks=mock_bg_tasks
    )

    assert result == "ProcessResponse"
    service.db.add.assert_called()
    service.db.commit.assert_called()
    service.db.refresh.assert_called()

    assert mock_send_email.call_count == 2


def test_start_adoption_animal_not_found(service):
    service.animal_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError, match="Animal not found"):
        service.start_adoption(999, "e@mail.com", "Name", MagicMock(), MagicMock())


def test_start_adoption_animal_not_in_adoption(service):
    service.animal_repo.get_by_id.return_value = _mock_animal(in_adoption=False)
    with pytest.raises(BusinessLogicError, match="Animal is not available for adoption"):
        service.start_adoption(100, "e@mail.com", "Name", MagicMock(), MagicMock())


def test_start_adoption_already_exists(service):
    service.animal_repo.get_by_id.return_value = _mock_animal(in_adoption=True)
    service.process_repo.get_active_process_for_animal.return_value = _mock_process()

    with pytest.raises(BusinessLogicError, match="An active adoption process already exists"):
        service.start_adoption(100, "e@mail.com", "Name", MagicMock(), MagicMock())

@patch("app.services.adoption_process_service.send_email")
def test_cancel_adoption_success(mock_send_email, service):
    mock_p = _mock_process(adoptant_id=200, status=AdoptionProcessStatusEnum.ACTIVE)
    service.process_repo.get_by_id.return_value = mock_p

    service.cancel_adoption(process_id=300, adoptant_id=200, background_tasks=MagicMock())

    service.step_repo.mark_all_rejected.assert_called_once_with(service.db, 300)
    service.process_repo.mark_rejected.assert_called_once_with(service.db, mock_p)
    mock_send_email.assert_called_once()


def test_cancel_adoption_unauthorized(service):
    mock_p = _mock_process(adoptant_id=200)
    service.process_repo.get_by_id.return_value = mock_p

    with pytest.raises(AuthorizationError, match="Not authorized to cancel this adoption process"):
        service.cancel_adoption(process_id=300, adoptant_id=999, background_tasks=MagicMock())


@patch("app.services.adoption_process_service.send_email")
def test_reject_adoption_success(mock_send_email, service):
    mock_p = _mock_process()
    service.process_repo.get_by_id.return_value = mock_p

    service._check_belongs_to_shelter = MagicMock()
    service.check_is_process_active = MagicMock()

    service.reject_adoption(300, shelter_id=1, reason="Not a good fit", background_tasks=MagicMock())

    service.step_repo.mark_all_rejected.assert_called_once_with(service.db, 300)
    service.process_repo.mark_rejected.assert_called_once_with(service.db, mock_p)
    mock_send_email.assert_called_once()

@patch("app.services.adoption_process_service.send_email")
def test_mark_process_completed(mock_send_email, service):
    mock_animal = _mock_animal(in_adoption=True)
    mock_p = _mock_process(animal=mock_animal)
    service.process_repo.get_by_id.return_value = mock_p

    service.mark_process_completed(300, background_tasks=MagicMock())

    service.process_repo.mark_completed.assert_called_once_with(service.db, mock_p)
    assert mock_p.animal.in_adoption is False
    mock_send_email.assert_called_once()

@patch("app.services.adoption_process_service.process_to_detail_response")
def test_get_adoption_process_details(mock_mapper, service):
    mock_p = _mock_process()
    service.process_repo.get_by_id.return_value = mock_p
    service.step_repo.get_steps_for_process.return_value = []

    service.get_adoption_process_details(300)

    mock_mapper.assert_called_once_with(mock_p, [])


def test_get_adoptant_success(service):
    mock_adoptant = _mock_adoptant()
    service.adoptant_repo.get_by_id.return_value = mock_adoptant
    service.adoptant_repo.has_process_in_shelter.return_value = True

    result = service.get_adoptant(200, shelter_id=1)
    assert result.id == 200


def test_get_adoptant_unauthorized(service):
    mock_adoptant = _mock_adoptant()
    service.adoptant_repo.get_by_id.return_value = mock_adoptant
    service.adoptant_repo.has_process_in_shelter.return_value = False

    with pytest.raises(AuthorizationError, match="Adoptant does not have an active adoption process"):
        service.get_adoptant(200, shelter_id=1)

@patch("app.services.adoption_process_service.cloudinary_uploader.upload")
@patch("app.services.adoption_process_service.pdf_service.generate_contract_pdf")
def test_generate_pdf_success(mock_pdf_gen, mock_cloudinary, service):
    mock_p = _mock_process()
    mock_contract = _mock_contract_step(status=StepStatusEnum.PENDING)

    service.process_repo.get_by_id.return_value = mock_p
    service.step_repo.get_steps_for_process.return_value = [mock_contract]

    mock_pdf_gen.return_value = b"pdf_bytes"
    mock_cloudinary.return_value = {
        "secure_url": "http://cloudinary.com/contract.pdf",
        "public_id": "contracts/contract_123"
    }

    url = service.generate_pdf(300, shelter_id=1)

    assert url == "http://cloudinary.com/contract.pdf"
    assert mock_contract.contract_url == "http://cloudinary.com/contract.pdf"
    service.db.commit.assert_called_once()
    mock_pdf_gen.assert_called_once_with(animal=mock_p.animal, adoptant=mock_p.adoptant)


def test_generate_pdf_invalid_state(service):
    mock_p = _mock_process()
    mock_contract = _mock_contract_step(status=StepStatusEnum.COMPLETED)

    service.process_repo.get_by_id.return_value = mock_p
    service.step_repo.get_steps_for_process.return_value = [mock_contract]

    with pytest.raises(BusinessLogicError, match="Contract step is not in a state that allows PDF generation"):
        service.generate_pdf(300, shelter_id=1)


def test_generate_pdf_no_contract_step(service):
    mock_p = _mock_process()
    service.process_repo.get_by_id.return_value = mock_p
    service.step_repo.get_steps_for_process.return_value = []

    with pytest.raises(NotFoundError, match="Contract step not found"):
        service.generate_pdf(300, shelter_id=1)