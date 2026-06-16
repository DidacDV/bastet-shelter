import pytest
from unittest.mock import MagicMock, patch
from fastapi import status
from app.main import app
from app.core.dependencies.role_dependencies import require_volunteer
from app.database import get_db

mock_user = MagicMock()
mock_user.id = 1
mock_auth = MagicMock()
mock_auth.user = mock_user
mock_auth.shelter_id = 1
mock_auth.role = "VOLUNTEER"


def _dashboard_response():
    return {
        "animal_count": 5,
        "volunteer_count": 3,
        "active_adoption_count": 1,
    }


@pytest.fixture(autouse=True)
def setup_auth():
    app.dependency_overrides[require_volunteer] = lambda: mock_auth
    yield
    app.dependency_overrides.pop(require_volunteer, None)


def test_get_dashboard_success(client):
    with patch("app.routers.dashboard_router.DashboardService") as mock_cls:
        mock_instance = MagicMock()
        mock_instance.get_dashboard.return_value = _dashboard_response()
        mock_cls.return_value = mock_instance

        response = client.get("/dashboard/")

        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "animal_count" in data
        assert data["animal_count"] == 5
        mock_instance.get_dashboard.assert_called_once_with(1)


def test_get_dashboard_requires_auth(client):
    """Without auth override the endpoint should require authentication."""
    app.dependency_overrides.pop(require_volunteer, None)

    response = client.get("/dashboard/")

    assert response.status_code in (status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN)
    # Restore for other tests
    app.dependency_overrides[require_volunteer] = lambda: mock_auth
