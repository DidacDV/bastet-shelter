import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.routers.adoption_steps_router import get_step_service
from app.core.dependencies.role_dependencies import require_manager, get_current_adoptant

mock_user = MagicMock()
mock_user.id = 1
mock_auth = MagicMock()
mock_auth.user = mock_user
mock_auth.shelter_id = 1
mock_auth.role = "MANAGER"

mock_adoptant = MagicMock()
mock_adoptant.id = 10
mock_adoptant.email = "adoptant@example.com"
mock_adoptant.name = "Ann"


def _form_response(**overrides):
    """Matches AdoptionFormResponse from adoption_form_schema (the AdoptionStepBaseResponse variant)."""
    data = {
        "id": 1,
        "status": "PENDING",
        "order": 1,
        "finish_date": None,
        "notes": None,
        "rejection_reason": None,
        "is_current": False,
        "type": "FORM",
        "accepted": False,
    }
    data.update(overrides)
    return data


def _interview_response(**overrides):
    """Matches InterviewResponse."""
    data = {
        "id": 2,
        "status": "PENDING",
        "order": 2,
        "finish_date": None,
        "notes": None,
        "rejection_reason": None,
        "is_current": True,
        "type": "INTERVIEW",
        "scheduled_at": None,
    }
    data.update(overrides)
    return data


def _shelter_visit_response(**overrides):
    """Matches ShelterVisitResponse."""
    data = {
        "id": 3,
        "status": "PENDING",
        "order": 3,
        "finish_date": None,
        "notes": None,
        "rejection_reason": None,
        "is_current": False,
        "type": "SHELTER_VISIT",
        "scheduled_at": None,
    }
    data.update(overrides)
    return data


def _animal_pickup_response(**overrides):
    """Matches AnimalPickupResponse."""
    data = {
        "id": 5,
        "status": "PENDING",
        "order": 5,
        "finish_date": None,
        "notes": None,
        "rejection_reason": None,
        "is_current": False,
        "type": "ANIMAL_PICKUP",
        "scheduled_at": None,
        "actual_pickup_at": None,
    }
    data.update(overrides)
    return data


def _contract_response(**overrides):
    """Matches ContractResponse."""
    data = {
        "id": 4,
        "status": "PENDING",
        "order": 4,
        "finish_date": None,
        "notes": None,
        "rejection_reason": None,
        "is_current": False,
        "type": "CONTRACT",
        "signed_by_adoptant": False,
        "signed_by_shelter": False,
        "contract_url": None,
    }
    data.update(overrides)
    return data


def _step_response(**overrides):
    """Matches AdoptionStepResponse (base with type)."""
    data = {
        "id": 1,
        "type": "INTERVIEW",
        "status": "PENDING",
        "order": 2,
        "finish_date": None,
        "notes": None,
        "rejection_reason": None,
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_service):
    app.dependency_overrides[get_step_service] = lambda: mock_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_adoptant] = lambda: mock_adoptant
    yield
    app.dependency_overrides = {}


def test_get_form_details_success(client, mock_service):
    mock_service.get_form_details.return_value = _form_response()

    response = client.get("/adoption/1/steps/form")

    assert response.status_code == status.HTTP_200_OK
    mock_service.get_form_details.assert_called_once_with(1)


def test_get_form_details_error(client, mock_service):
    mock_service.get_form_details.side_effect = ValueError("Process is unavailable")

    response = client.get("/adoption/999/steps/form")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_set_interview_date_success(client, mock_service):
    mock_service.set_interview_scheduled_date.return_value = _interview_response(
        scheduled_at="2026-02-01T10:00:00"
    )

    # ScheduledDateUpdate uses "scheduled_at" field
    response = client.patch("/adoption/1/steps/interview", json={
        "scheduled_at": "2026-02-01T10:00:00"
    })

    assert response.status_code == status.HTTP_200_OK
    mock_service.set_interview_scheduled_date.assert_called_once()


def test_set_shelter_visit_date_success(client, mock_service):
    mock_service.set_shelter_visit_scheduled_date.return_value = _shelter_visit_response(
        scheduled_at="2026-02-10T10:00:00"
    )

    response = client.patch("/adoption/1/steps/shelter-visit", json={
        "scheduled_at": "2026-02-10T10:00:00"
    })

    assert response.status_code == status.HTTP_200_OK
    mock_service.set_shelter_visit_scheduled_date.assert_called_once()


def test_set_animal_pickup_date_success(client, mock_service):
    mock_service.set_animal_pickup_scheduled_date.return_value = _animal_pickup_response(
        scheduled_at="2026-02-20T10:00:00"
    )

    response = client.patch("/adoption/1/steps/pickup", json={
        "scheduled_at": "2026-02-20T10:00:00"
    })

    assert response.status_code == status.HTTP_200_OK
    mock_service.set_animal_pickup_scheduled_date.assert_called_once()


def test_set_actual_pickup_date_success(client, mock_service):
    mock_service.set_animal_pickup_actual_date.return_value = _animal_pickup_response(
        actual_pickup_at="2026-02-21T10:00:00"
    )

    response = client.patch("/adoption/1/steps/3/actual-pickup", json={
        "scheduled_at": "2026-02-21T10:00:00"
    })

    assert response.status_code == status.HTTP_200_OK
    mock_service.set_animal_pickup_actual_date.assert_called_once()


def test_add_notes_success(client, mock_service):
    mock_service.add_notes.return_value = _step_response(notes="Good candidate")

    response = client.patch("/adoption/1/steps/1/notes", json={"notes": "Good candidate"})

    assert response.status_code == status.HTTP_200_OK
    mock_service.add_notes.assert_called_once()


def test_add_notes_error(client, mock_service):
    mock_service.add_notes.side_effect = ValueError("Step is unavailable")

    response = client.patch("/adoption/1/steps/999/notes", json={"notes": "Test"})

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_update_adoptant_signature_success(client, mock_service):
    mock_service.update_adoptant_signature.return_value = _contract_response(signed_by_adoptant=True)

    response = client.patch("/adoption/1/steps/contract/adoptant-signature")

    assert response.status_code == status.HTTP_200_OK
    mock_service.update_adoptant_signature.assert_called_once_with(1, 10)


def test_update_adoptant_signature_error(client, mock_service):
    mock_service.update_adoptant_signature.side_effect = ValueError("Process is unavailable")

    response = client.patch("/adoption/999/steps/contract/adoptant-signature")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_update_shelter_signature_success(client, mock_service):
    mock_service.update_shelter_signature.return_value = _contract_response(signed_by_shelter=True)

    response = client.patch("/adoption/1/steps/contract/shelter-signature")

    assert response.status_code == status.HTTP_200_OK
    mock_service.update_shelter_signature.assert_called_once_with(1)


def test_update_shelter_signature_error(client, mock_service):
    mock_service.update_shelter_signature.side_effect = ValueError("Process is unavailable")

    response = client.patch("/adoption/999/steps/contract/shelter-signature")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_step_service(db):
    from app.routers.adoption_steps_router import get_step_service
    from app.services.adoption_steps_service import AdoptionStepsService
    service = get_step_service(db)
    assert isinstance(service, AdoptionStepsService)
