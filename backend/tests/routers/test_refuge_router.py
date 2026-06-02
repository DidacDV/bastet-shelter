import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.routers.refuge_router import get_refuge_service
from app.core.dependencies.role_dependencies import get_current_user, require_manager

mock_user = MagicMock()
mock_user.id = 1
mock_auth = MagicMock()
mock_auth.user = mock_user
mock_auth.shelter_id = 1
mock_auth.role = "MANAGER"


def _province():
    return {"id": "08", "name": "Barcelona"}


def _refuge_response(**overrides):
    data = {
        "id": 1,
        "name": "Main Refuge",
        "province": _province(),
        "shelter_id": 1,
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_service):
    app.dependency_overrides[get_refuge_service] = lambda: mock_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_user] = lambda: mock_auth
    yield
    app.dependency_overrides = {}


def test_create_refuge_success(client, mock_service):
    mock_service.create_refuge.return_value = _refuge_response()

    response = client.post("/refuges/", json={"name": "Main Refuge", "province_id": "08"})

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["name"] == "Main Refuge"
    mock_service.create_refuge.assert_called_once()


def test_create_refuge_error(client, mock_service):
    mock_service.create_refuge.side_effect = ValueError("Province is invalid")

    response = client.post("/refuges/", json={"name": "Main Refuge", "province_id": "99"})

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_refuges_success(client, mock_service):
    mock_service.get_refuges.return_value = [_refuge_response()]

    response = client.get("/refuges/")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()) == 1
    mock_service.get_refuges.assert_called_once_with(1)


def test_get_refuges_empty(client, mock_service):
    mock_service.get_refuges.return_value = []

    response = client.get("/refuges/")

    assert response.status_code == status.HTTP_200_OK
    assert response.json() == []


def test_update_refuge_success(client, mock_service):
    mock_service.update_refuge.return_value = _refuge_response(name="Updated Refuge")

    response = client.put("/refuges/1", json={"name": "Updated Refuge"})

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["name"] == "Updated Refuge"
    mock_service.update_refuge.assert_called_once()


def test_update_refuge_error(client, mock_service):
    mock_service.update_refuge.side_effect = ValueError("Refuge does not exist")

    response = client.put("/refuges/999", json={"name": "Updated Refuge"})

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_delete_refuge_success(client, mock_service):
    response = client.delete("/refuges/1")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_service.delete_refuge.assert_called_once_with(1, 1)


def test_delete_refuge_error(client, mock_service):
    mock_service.delete_refuge.side_effect = ValueError("Cannot delete last refuge")

    response = client.delete("/refuges/1")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_refuge_service(db):
    from app.routers.refuge_router import get_refuge_service
    from app.services.refuge_service import RefugeService
    service = get_refuge_service(db)
    assert isinstance(service, RefugeService)
