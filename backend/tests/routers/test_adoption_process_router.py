import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.routers.adoption_process_router import get_process_service, get_step_service
from app.core.dependencies.role_dependencies import require_manager, require_volunteer, get_current_adoptant

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


def _process_response(**overrides):
    """Matches AdoptionProcessResponse schema."""
    data = {
        "id": 1,
        "animal_id": 1,
        "animal_name": "Buddy",
        "animal_image_url": None,
        "adoptant_id": 10,
        "adoptant_name": "Ann",
        "start_date": "2026-01-01",
        "end_date": None,
        "status": "ACTIVE",
        "steps": [],
        "rejection_reason": None,
    }
    data.update(overrides)
    return data


def _process_detail_response(**overrides):
    """Matches AdoptionProcessDetailResponse schema (steps are AnyStepDetailResponse)."""
    data = {
        "id": 1,
        "animal_id": 1,
        "animal_name": "Buddy",
        "animal_image_url": None,
        "adoptant_id": 10,
        "adoptant_name": "Ann",
        "start_date": "2026-01-01",
        "end_date": None,
        "status": "ACTIVE",
        "steps": [],
        "rejection_reason": None,
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_process_service():
    return MagicMock()


@pytest.fixture
def mock_step_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_process_service, mock_step_service):
    app.dependency_overrides[get_process_service] = lambda: mock_process_service
    app.dependency_overrides[get_step_service] = lambda: mock_step_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[require_volunteer] = lambda: mock_auth
    app.dependency_overrides[get_current_adoptant] = lambda: mock_adoptant
    yield
    app.dependency_overrides = {}


def test_start_adoption_success(client, mock_process_service):
    mock_process_service.start_adoption.return_value = _process_response()

    response = client.post("/adoption/start/1", json={
        "housing_type": "HOUSE",
        "has_garden": True,
    })

    assert response.status_code == status.HTTP_201_CREATED
    mock_process_service.start_adoption.assert_called_once()


def test_start_adoption_error(client, mock_process_service):
    mock_process_service.start_adoption.side_effect = ValueError("Animal is unavailable")

    response = client.post("/adoption/start/999", json={})

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_cancel_adoption_success(client, mock_process_service):
    response = client.post("/adoption/1/cancel")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_process_service.cancel_adoption.assert_called_once()


def test_reject_adoption_process_success(client, mock_process_service):
    response = client.post("/adoption/1/reject", json={"reason": "Not suitable"})

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_process_service.reject_adoption.assert_called_once()


def test_get_all_processes_for_shelter_success(client, mock_process_service):
    mock_process_service.get_all_processes_for_shelter.return_value = [_process_response()]

    response = client.get("/adoption/shelter")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["processes"]) == 1
    mock_process_service.get_all_processes_for_shelter.assert_called_once_with(1)


def test_get_adoption_process_manager_success(client, mock_process_service):
    mock_process_service.get_adoption_process_steps_manager.return_value = _process_detail_response()

    response = client.get("/adoption/1/manager")

    assert response.status_code == status.HTTP_200_OK
    mock_process_service.get_adoption_process_steps_manager.assert_called_once_with(1, 1)


def test_get_adoption_process_manager_error(client, mock_process_service):
    mock_process_service.get_adoption_process_steps_manager.side_effect = ValueError("Process is unavailable")

    response = client.get("/adoption/999/manager")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_adoption_process_details_success(client, mock_process_service):
    mock_process_service.get_adoption_process_details.return_value = _process_detail_response()

    response = client.get("/adoption/1/details")

    assert response.status_code == status.HTTP_200_OK
    mock_process_service.get_adoption_process_details.assert_called_once_with(1)


def test_advance_current_step_success(client, mock_process_service, mock_step_service):
    mock_step_service.has_pending_steps.return_value = True
    mock_process_service.get_adoption_process_steps_manager.return_value = _process_detail_response()

    response = client.post("/adoption/1/advance", json={"notes": "Step completed"})

    assert response.status_code == status.HTTP_200_OK
    mock_process_service.check_is_process_active.assert_called_once_with(1)
    mock_step_service.advance_current_step.assert_called_once()


def test_advance_current_step_completes_process(client, mock_process_service, mock_step_service):
    mock_step_service.has_pending_steps.return_value = False
    mock_process_service.get_adoption_process_steps_manager.return_value = _process_detail_response(status="COMPLETED")

    response = client.post("/adoption/1/advance", json={"notes": "Last step"})

    assert response.status_code == status.HTTP_200_OK
    mock_process_service.mark_process_completed.assert_called_once()


def test_skip_step_success(client, mock_process_service, mock_step_service):
    mock_step_service.has_pending_steps.return_value = True
    mock_process_service.get_adoption_process_steps_manager.return_value = _process_detail_response()

    response = client.post("/adoption/1/skip")

    assert response.status_code == status.HTTP_200_OK
    mock_step_service.skip_step.assert_called_once_with(1)


def test_skip_step_completes_process(client, mock_process_service, mock_step_service):
    mock_step_service.has_pending_steps.return_value = False
    mock_process_service.get_adoption_process_steps_manager.return_value = _process_detail_response(status="COMPLETED")

    response = client.post("/adoption/1/skip")

    assert response.status_code == status.HTTP_200_OK
    mock_process_service.mark_process_completed.assert_called_once()


def test_generate_pdf_success(client, mock_process_service):
    mock_process_service.generate_pdf.return_value = "https://example.com/contract.pdf"

    response = client.post("/adoption/1/pdf")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["contract_url"] == "https://example.com/contract.pdf"
    mock_process_service.generate_pdf.assert_called_once_with(1, 1)


def test_generate_pdf_error(client, mock_process_service):
    mock_process_service.generate_pdf.side_effect = ValueError("Process is unavailable")

    response = client.post("/adoption/999/pdf")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_process_service(db):
    from app.routers.adoption_process_router import get_process_service
    from app.services.adoption_process_service import AdoptionProcessService
    service = get_process_service(db)
    assert isinstance(service, AdoptionProcessService)
