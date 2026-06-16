import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.routers.trait_router import get_trait_service
from app.core.dependencies.role_dependencies import get_current_user, require_manager

mock_user = MagicMock()
mock_user.id = 1
mock_auth = MagicMock()
mock_auth.user = mock_user
mock_auth.shelter_id = 1
mock_auth.role = "MANAGER"


def _trait_response(**overrides):
    data = {
        "id": 1,
        "name": "Friendly",
        "shelter_id": 1,
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_service):
    app.dependency_overrides[get_trait_service] = lambda: mock_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_user] = lambda: mock_auth
    yield
    app.dependency_overrides = {}


def test_get_traits_success(client, mock_service):
    mock_service.get_traits.return_value = [_trait_response()]

    response = client.get("/traits/")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["traits"]) == 1
    mock_service.get_traits.assert_called_once_with(1)


def test_get_traits_empty(client, mock_service):
    mock_service.get_traits.return_value = []

    response = client.get("/traits/")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["traits"] == []


def test_add_trait_success(client, mock_service):
    mock_service.add_trait.return_value = _trait_response()

    response = client.post("/traits/", json={"name": "Friendly"})

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["name"] == "Friendly"
    mock_service.add_trait.assert_called_once()


def test_add_trait_error(client, mock_service):
    mock_service.add_trait.side_effect = ValueError("Trait already exists")

    response = client.post("/traits/", json={"name": "Friendly"})

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_edit_trait_success(client, mock_service):
    mock_service.edit_trait.return_value = _trait_response(name="Calm")

    response = client.put("/traits/1", json={"name": "Calm"})

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["name"] == "Calm"
    mock_service.edit_trait.assert_called_once()


def test_edit_trait_error(client, mock_service):
    mock_service.edit_trait.side_effect = ValueError("Trait is already removed")

    response = client.put("/traits/999", json={"name": "Calm"})

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_delete_trait_success(client, mock_service):
    response = client.delete("/traits/1")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_service.delete_trait.assert_called_once_with(1, 1)


def test_delete_trait_error(client, mock_service):
    mock_service.delete_trait.side_effect = ValueError("Trait is already removed")

    response = client.delete("/traits/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_trait_service(db):
    from app.routers.trait_router import get_trait_service
    from app.services.trait_service import TraitService
    service = get_trait_service(db)
    assert isinstance(service, TraitService)
