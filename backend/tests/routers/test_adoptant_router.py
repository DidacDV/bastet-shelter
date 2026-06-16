import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.routers.adoptant_router import get_process_service
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


def _adoptant_process_adoptant_response(**overrides):
    """Matches AdoptionProcessAdoptantResponse schema."""
    data = {
        "id": 1,
        "animal_id": 1,
        "animal_name": "Buddy",
        "animal_image_url": None,
        "start_date": "2026-01-01",
        "end_date": None,
        "status": "ACTIVE",
        "rejection_reason": None,
        "current_step": None,
        "steps": [],
    }
    data.update(overrides)
    return data


def _adoptant_response(**overrides):
    """Matches AdoptantResponse schema."""
    data = {
        "id": 10,
        "name": "Ann",
        "email": "adoptant@example.com",
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_service):
    app.dependency_overrides[get_process_service] = lambda: mock_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_adoptant] = lambda: mock_adoptant
    yield
    app.dependency_overrides = {}


def test_get_all_processes_for_adoptant_success(client, mock_service):
    mock_service.get_all_processes_for_adoptant.return_value = [_process_response()]

    response = client.get("/adoptant/processes")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()) == 1
    mock_service.get_all_processes_for_adoptant.assert_called_once_with(10)


def test_get_all_processes_for_adoptant_empty(client, mock_service):
    mock_service.get_all_processes_for_adoptant.return_value = []

    response = client.get("/adoptant/processes")

    assert response.status_code == status.HTTP_200_OK
    assert response.json() == []


def test_get_adoption_process_adoptant_success(client, mock_service):
    mock_service.get_adoption_process_steps_adoptant.return_value = _adoptant_process_adoptant_response()

    response = client.get("/adoptant/processes/1")

    assert response.status_code == status.HTTP_200_OK
    mock_service.get_adoption_process_steps_adoptant.assert_called_once_with(1, 10)


def test_get_adoption_process_adoptant_error(client, mock_service):
    mock_service.get_adoption_process_steps_adoptant.side_effect = ValueError("Process is unavailable")

    response = client.get("/adoptant/processes/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_adoptant_success(client, mock_service):
    mock_service.get_adoptant.return_value = _adoptant_response()

    response = client.get("/adoptant/10")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["id"] == 10
    mock_service.get_adoptant.assert_called_once_with(10, 1)


def test_get_adoptant_not_found(client, mock_service):
    from app.core.exceptions import NotFoundError
    mock_service.get_adoptant.side_effect = NotFoundError("Adoptant not found")

    response = client.get("/adoptant/999")

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Adoptant not found" in response.json()["detail"]


def test_get_adoptant_unauthorized(client, mock_service):
    from app.core.exceptions import AuthorizationError
    mock_service.get_adoptant.side_effect = AuthorizationError("No access")

    response = client.get("/adoptant/10")

    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_get_process_service(db):
    from app.routers.adoptant_router import get_process_service
    from app.services.adoption_process_service import AdoptionProcessService
    service = get_process_service(db)
    assert isinstance(service, AdoptionProcessService)
