import pytest
from unittest.mock import MagicMock, call

from app.core.exceptions import NotFoundError
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

    with pytest.raises(NotFoundError, match=f"User with email {email} not found"):
        service.get_user(email)
    service.repository.get_by_email.assert_called_once_with(service.db, email)


def test_delete_user_not_found(service):
    service.repository.get_by_id.return_value = None

    with pytest.raises(NotFoundError, match="User not found"):
        service.delete_user(99)

    service.repository.get_by_id.assert_called_once_with(service.db, 99)
    service.db.delete.assert_not_called()
    service.db.commit.assert_not_called()


def test_delete_user_success_with_member_participants_and_login(service):
    """Full path: user has a member, the member has participants, and the user has a login."""
    user_id = 1

    mock_user = MagicMock()
    mock_user.login = MagicMock()
    service.repository.get_by_id.return_value = mock_user

    mock_member = MagicMock()
    mock_member.id = 10

    mock_participant = MagicMock()
    mock_participant.id = 20

    query_side_effects = [
        MagicMock(**{"filter.return_value.first.return_value": mock_member}),
        MagicMock(**{"filter.return_value.all.return_value": [mock_participant]}),
        MagicMock(**{"filter.return_value.update.return_value": 1}),
    ]
    service.db.query.side_effect = query_side_effects

    service.delete_user(user_id)

    service.db.delete.assert_any_call(mock_participant)
    service.db.delete.assert_any_call(mock_member)
    service.db.delete.assert_any_call(mock_user.login)
    service.db.delete.assert_any_call(mock_user)
    service.db.commit.assert_called_once()


def test_delete_user_success_no_member_no_login(service):
    """User has no ShelterMember and no login."""
    user_id = 2

    mock_user = MagicMock()
    mock_user.login = None
    service.repository.get_by_id.return_value = mock_user

    service.db.query.return_value.filter.return_value.first.return_value = None

    service.delete_user(user_id)

    service.db.delete.assert_called_once_with(mock_user)
    service.db.commit.assert_called_once()


def test_delete_user_success_member_but_no_participants(service):
    """User has a ShelterMember but that member has no ShiftParticipants."""
    user_id = 3

    mock_user = MagicMock()
    mock_user.login = None
    service.repository.get_by_id.return_value = mock_user

    mock_member = MagicMock()
    mock_member.id = 10

    query_side_effects = [
        MagicMock(**{"filter.return_value.first.return_value": mock_member}),
        MagicMock(**{"filter.return_value.all.return_value": []}),
    ]
    service.db.query.side_effect = query_side_effects

    service.delete_user(user_id)

    service.db.delete.assert_any_call(mock_member)
    service.db.delete.assert_any_call(mock_user)
    service.db.commit.assert_called_once()
