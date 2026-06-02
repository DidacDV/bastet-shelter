import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.routers.advertisement_router import get_advertisement_service
from app.core.dependencies.role_dependencies import get_current_user, require_manager
from datetime import datetime

mock_user = MagicMock()
mock_user.id = 1
mock_auth = MagicMock()
mock_auth.user = mock_user
mock_auth.shelter_id = 1
mock_auth.role = "MANAGER"


def _ad_summary_response(**overrides):
    data = {
        "id": 1,
        "title": "Pet Food Donation",
        "category": "FOOD",
        "province_name": "Barcelona",
        "image_url": None,
        "is_active": True,
    }
    data.update(overrides)
    return data


def _ad_detail_response(**overrides):
    data = {
        "id": 1,
        "title": "Pet Food Donation",
        "category": "FOOD",
        "province_name": "Barcelona",
        "image_url": None,
        "is_active": True,
        "description": "We need pet food donations",
        "published_on": "2026-01-01T00:00:00",
        "shelter_id": 1,
        "shelter_name": "Happy Paws",
        "shelter_email": "contact@happypaws.com",
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_service):
    app.dependency_overrides[get_advertisement_service] = lambda: mock_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_user] = lambda: mock_auth
    yield
    app.dependency_overrides = {}


def test_create_advertisement_success(client, mock_service):
    mock_service.create_advertisement.return_value = _ad_detail_response()

    response = client.post("/advertisements/", json={
        "title": "Pet Food Donation",
        "description": "We need pet food donations",
        "category": "FOOD",
        "province_name": "Barcelona",
    })

    assert response.status_code == status.HTTP_201_CREATED
    assert response.json()["title"] == "Pet Food Donation"
    mock_service.create_advertisement.assert_called_once()


def test_create_advertisement_error(client, mock_service):
    mock_service.create_advertisement.side_effect = ValueError("Province is invalid")

    response = client.post("/advertisements/", json={
        "title": "Pet Food Donation",
        "description": "We need pet food donations",
        "category": "FOOD",
        "province_name": "Barcelona",
    })

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_my_advertisements_success(client, mock_service):
    mock_service.get_my_advertisements.return_value = [_ad_summary_response()]

    response = client.get("/advertisements/me")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["advertisements"]) == 1
    mock_service.get_my_advertisements.assert_called_once_with(1)


def test_get_advertisements_success(client, mock_service):
    mock_service.get_advertisements.return_value = [_ad_summary_response()]

    response = client.get("/advertisements/")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["advertisements"]) == 1
    mock_service.get_advertisements.assert_called_once()


def test_get_advertisements_with_filters(client, mock_service):
    mock_service.get_advertisements.return_value = [_ad_summary_response()]

    response = client.get("/advertisements/?province_name=Barcelona&category=FOOD")

    assert response.status_code == status.HTTP_200_OK
    mock_service.get_advertisements.assert_called_once()


def test_get_advertisement_detail_success(client, mock_service):
    mock_service.get_advertisement_by_id.return_value = _ad_detail_response()

    response = client.get("/advertisements/1")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["id"] == 1
    mock_service.get_advertisement_by_id.assert_called_once_with(1)


def test_get_advertisement_detail_error(client, mock_service):
    mock_service.get_advertisement_by_id.side_effect = ValueError("Ad is unavailable")

    response = client.get("/advertisements/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_deactivate_advertisement_success(client, mock_service):
    mock_service.deactivate_advertisement.return_value = _ad_detail_response(is_active=False)

    response = client.patch("/advertisements/1/deactivate")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["is_active"] is False
    mock_service.deactivate_advertisement.assert_called_once_with(1, 1)


def test_deactivate_advertisement_error(client, mock_service):
    mock_service.deactivate_advertisement.side_effect = ValueError("Ad is already inactive")

    response = client.patch("/advertisements/999/deactivate")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_delete_advertisement_image_success(client, mock_service):
    mock_service.delete_image.return_value = _ad_detail_response()

    response = client.delete("/advertisements/1/image")

    assert response.status_code == status.HTTP_200_OK
    mock_service.delete_image.assert_called_once_with(1, 1)


def test_delete_advertisement_image_error(client, mock_service):
    mock_service.delete_image.side_effect = ValueError("No image to delete")

    response = client.delete("/advertisements/999/image")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_advertisement_service(db):
    from app.routers.advertisement_router import get_advertisement_service
    from app.services.advertisement_service import AdvertisementService
    service = get_advertisement_service(db)
    assert isinstance(service, AdvertisementService)
