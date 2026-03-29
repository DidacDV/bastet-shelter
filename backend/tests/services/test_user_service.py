import pytest
from unittest.mock import MagicMock
from app.services.user_service import UserService

@pytest.fixture
def service():
    repository = MagicMock()
    db = MagicMock()
    return UserService(repository, db)

def test_get_user_success(service):
    email = "test@example.com"
    mock_user = MagicMock()
    mock_user.email = email
    service.repository.get_by_email.return_value = mock_user

    result = service.get_user(email)

    assert result == mock_user
    assert result.email == email
    service.repository.get_by_email.assert_called_once_with(service.db, email)

def test_get_user_not_found(service):
    email = "nonexistent@example.com"
    service.repository.get_by_email.return_value = None

    with pytest.raises(ValueError, match=f"User with email {email} not found"):
        service.get_user(email)
    service.repository.get_by_email.assert_called_once_with(service.db, email)
