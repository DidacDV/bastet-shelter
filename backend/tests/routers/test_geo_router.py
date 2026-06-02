import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.database import get_db
from app.services.geo_service import GeoService


def _province_response(**overrides):
    data = {"id": "08", "name": "Barcelona", "community_code": "09"}
    data.update(overrides)
    return data


def test_get_provinces_success(client, db):
    response = client.get("/geo/provinces")

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "provinces" in data
    # The conftest seeds one province ("08" - Barcelona)
    assert any(p["id"] == "08" for p in data["provinces"])


def test_get_provinces_returns_list(client, db):
    response = client.get("/geo/provinces")

    assert response.status_code == status.HTTP_200_OK
    assert isinstance(response.json()["provinces"], list)


def test_get_provinces_no_auth_required(client):
    """Geo endpoint is public - no authentication needed."""
    response = client.get("/geo/provinces")

    assert response.status_code == status.HTTP_200_OK
