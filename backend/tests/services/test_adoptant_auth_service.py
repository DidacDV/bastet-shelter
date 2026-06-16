import pytest
from datetime import datetime
from unittest.mock import MagicMock, patch

from app.core.exceptions import AuthorizationError
from app.services.adoptant_auth_service import AdoptantAuthService
from app.schemas.adoption_schema.magic_link_schema import AdoptantTokenResponse

@pytest.fixture
def service():
    db = MagicMock()
    s = AdoptantAuthService(db)
    s.adoptant_repo = MagicMock()
    s.token_repo = MagicMock()
    return s


def _mock_request(email="user@example.com", name="Alice"):
    req = MagicMock()
    req.email = email
    req.name = name
    return req

@patch("app.services.adoptant_auth_service.send_email")
def test_request_magic_link_new_adoptant(mock_send_email, service):
    """When get_by_email returns None, a new Adoptant is created."""
    service.adoptant_repo.get_by_email.return_value = None

    def mock_create(db, adoptant_obj):
        adoptant_obj.id = 123
        return adoptant_obj
    service.adoptant_repo.create.side_effect = mock_create

    bg = MagicMock()
    result = service.request_magic_link(_mock_request(), bg)

    service.adoptant_repo.create.assert_called_once()
    service.token_repo.create.assert_called_once()
    mock_send_email.assert_called_once()
    assert result == {"message": "If the details are correct, a login link has been sent to your email."}

@patch("app.services.adoptant_auth_service.send_email")
def test_request_magic_link_existing_adoptant_same_name(mock_send_email, service):
    """When adoptant already exists with the same name, no update (no db.commit)."""
    existing = MagicMock()
    existing.id = 1
    existing.name = "Alice"
    existing.email = "user@example.com"
    service.adoptant_repo.get_by_email.return_value = existing

    bg = MagicMock()
    service.request_magic_link(_mock_request(name="Alice"), bg)

    # create should NOT be called (adoptant already exists)
    service.adoptant_repo.create.assert_not_called()
    # commit should NOT be called (name unchanged)
    service.db.commit.assert_not_called()
    mock_send_email.assert_called_once()


@patch("app.services.adoptant_auth_service.send_email")
def test_request_magic_link_existing_adoptant_different_name(mock_send_email, service):
    """When adoptant exists but name differs, the name is updated and db.commit is called."""
    existing = MagicMock()
    existing.id = 1
    existing.name = "OldName"
    existing.email = "user@example.com"
    service.adoptant_repo.get_by_email.return_value = existing

    bg = MagicMock()
    service.request_magic_link(_mock_request(name="NewName"), bg)

    assert existing.name == "NewName"
    service.db.commit.assert_called_once()
    service.adoptant_repo.create.assert_not_called()
    mock_send_email.assert_called_once()

def test_verify_magic_link_invalid_token(service):
    """When token is not found, AuthorizationError is raised."""
    service.token_repo.get_by_token.return_value = None

    with pytest.raises(AuthorizationError, match="Invalid token"):
        service.verify_magic_link("not-a-real-token")


def test_verify_magic_link_expired_token(service):
    """When token is expired (expires_at in the past), AuthorizationError is raised."""
    magic_link = MagicMock()
    magic_link.expires_at = datetime(2020, 1, 1)  # well in the past
    magic_link.adoptant = MagicMock()
    service.token_repo.get_by_token.return_value = magic_link

    with pytest.raises(AuthorizationError, match="Token has expired"):
        service.verify_magic_link("expired-token")


@patch("app.services.adoptant_auth_service.create_access_token", return_value="mocked.jwt.token")
def test_verify_magic_link_success(mock_create_token, service):
    """Valid, non-expired token returns an AdoptantTokenResponse with an access_token."""
    magic_link = MagicMock()
    # expires_at far in the future so the service considers it valid
    magic_link.expires_at = datetime(2099, 1, 1)
    magic_link.adoptant = MagicMock()
    magic_link.adoptant.email = "user@example.com"
    magic_link.adoptant.id = 42
    magic_link.adoptant.name = "Alice"
    service.token_repo.get_by_token.return_value = magic_link

    result = service.verify_magic_link("valid-token")

    assert isinstance(result, AdoptantTokenResponse)
    assert result.access_token == "mocked.jwt.token"
    assert result.token_type == "bearer"
    assert result.adoptant_name == "Alice"
    mock_create_token.assert_called_once()
