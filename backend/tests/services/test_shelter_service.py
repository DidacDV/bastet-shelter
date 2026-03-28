import pytest
from unittest.mock import MagicMock, patch
from datetime import date

from app.services.shelter_service import ShelterService
from app.models.shelter_member import RoleEnum
from app.schemas.shelter_schema import ShelterCreate


def _mock_shelter(volunteer_code="VOL123", manager_code="MAN456"):
    shelter = MagicMock()
    shelter.id = 1
    shelter.name = "Rodamons"
    shelter.province_id = "08"
    shelter.province = MagicMock()
    shelter.province.id = "08"
    shelter.province.name = "Barcelona"
    shelter.volunteer_code = volunteer_code
    shelter.manager_code = manager_code
    return shelter


def _mock_member(role: RoleEnum):
    """Returns a mock with real role and date values so pydantic doesnt throw error"""
    member = MagicMock()
    member.role = role
    member.join_date = date.today()
    member.user_id = 1
    member.shelter_id = 1
    return member


@pytest.fixture
def service():
    db = MagicMock()
    s = ShelterService(db)
    s.shelter_repo = MagicMock()
    s.member_repo = MagicMock()
    s.member_repo.create.side_effect = lambda db, m: _mock_member(m.role)
    return s


#region CREATE_SHELTER

def test_create_shelter_returns_token_and_shelter(service):
    service.shelter_repo.create.return_value = _mock_shelter()

    result = service.create_shelter(
        data=ShelterCreate(name="Rodamons", province_id="08", refuge_name="refuge"),
        user_id=1,
        user_email="owner@example.com"
    )

    assert "access_token" in result
    assert result["token_type"] == "bearer"
    assert result["shelter"].name == "Rodamons"


def test_create_shelter_adds_user_as_manager(service):
    service.shelter_repo.create.return_value = _mock_shelter()

    service.create_shelter(
        data=ShelterCreate(name="Rodamons", province_id="08", refuge_name="refuge"),
        user_id=1,
        user_email="owner@example.com"
    )

    service.member_repo.create.assert_called_once()
    created_member = service.member_repo.create.call_args[0][1]
    assert created_member.role == RoleEnum.MANAGER

#endregion

#region JOIN_AS_VOLUNTEER

def test_join_as_volunteer_success(service):
    service.shelter_repo.get_by_volunteer_code.return_value = _mock_shelter()

    result = service.join_as_volunteer(user_id=2, shelter_code="VOL123", user_email="vol@example.com")

    assert "access_token" in result
    service.member_repo.create.assert_called_once()


def test_join_as_volunteer_creates_volunteer_member(service):
    service.shelter_repo.get_by_volunteer_code.return_value = _mock_shelter()

    service.join_as_volunteer(user_id=2, shelter_code="VOL123", user_email="vol@example.com")

    created_member = service.member_repo.create.call_args[0][1]
    assert created_member.role == RoleEnum.VOLUNTEER


def test_join_as_volunteer_invalid_code_raises(service):
    service.shelter_repo.get_by_volunteer_code.return_value = None

    with pytest.raises(ValueError, match="Invalid volunteer code"):
        service.join_as_volunteer(user_id=2, shelter_code="WRONG", user_email="vol@example.com")


def test_join_as_volunteer_rejects_manager_code(service):
    service.shelter_repo.get_by_volunteer_code.return_value = None

    with pytest.raises(ValueError, match="Invalid volunteer code"):
        service.join_as_volunteer(user_id=2, shelter_code="MAN456", user_email="vol@example.com")

#endregion

#region JOIN_AS_MANAGER
def test_join_as_manager_success(service):
    service.shelter_repo.get_by_manager_code.return_value = _mock_shelter()

    result = service.join_as_manager(user_id=3, shelter_code="MAN456", user_email="mgr@example.com")

    assert "access_token" in result
    service.member_repo.create.assert_called_once()


def test_join_as_manager_creates_manager_member(service):
    service.shelter_repo.get_by_manager_code.return_value = _mock_shelter()

    service.join_as_manager(user_id=3, shelter_code="MAN456", user_email="mgr@example.com")

    created_member = service.member_repo.create.call_args[0][1]
    assert created_member.role == RoleEnum.MANAGER


def test_join_as_manager_invalid_code_raises(service):
    service.shelter_repo.get_by_manager_code.return_value = None

    with pytest.raises(ValueError, match="Invalid manager code"):
        service.join_as_manager(user_id=3, shelter_code="WRONG", user_email="mgr@example.com")


def test_join_as_manager_rejects_volunteer_code(service):
    service.shelter_repo.get_by_manager_code.return_value = None

    with pytest.raises(ValueError, match="Invalid manager code"):
        service.join_as_manager(user_id=3, shelter_code="VOL123", user_email="mgr@example.com")
#endregion

#region GET_BY_USER
def test_get_by_user_returns_member_info(service):
    mock_member = MagicMock()
    mock_member.shelter.name = "Rodamons"
    mock_member.role = RoleEnum.VOLUNTEER
    mock_member.join_date = date.today()
    service.member_repo.get_by_user.return_value = mock_member

    result = service.get_by_user(user_id=1)

    assert result is not None
    assert result.name == "Rodamons"
    assert result.role == RoleEnum.VOLUNTEER


def test_get_by_user_no_membership_returns_none(service):
    service.member_repo.get_by_user.return_value = None

    result = service.get_by_user(user_id=1)

    assert result is None
#endregion

# region RESET_CODES

def test_reset_volunteer_code_returns_new_code(service):
    service.shelter_repo.get_by_id.return_value = _mock_shelter()

    with patch("app.services.shelter_service.generate_code", return_value="DACDAC11"):
        result = service.reset_volunteer_code(shelter_id=1)

    assert result == "DACDAC11"
    service.shelter_repo.update_volunteer_code.assert_called_once_with(service.db, 1, "DACDAC11")


def test_reset_manager_code_returns_new_code(service):
    service.shelter_repo.get_by_id.return_value = _mock_shelter()

    with patch("app.services.shelter_service.generate_code", return_value="DACDAC11"):
        result = service.reset_manager_code(shelter_id=1)

    assert result == "DACDAC11"
    service.shelter_repo.update_manager_code.assert_called_once_with(service.db, 1, "DACDAC11")


def test_reset_volunteer_code_shelter_not_found(service):
    service.shelter_repo.get_by_id.return_value = None

    with pytest.raises(ValueError, match="not found"):
        service.reset_volunteer_code(shelter_id=999)


def test_reset_manager_code_shelter_not_found(service):
    service.shelter_repo.get_by_id.return_value = None

    with pytest.raises(ValueError, match="not found"):
        service.reset_manager_code(shelter_id=999)

#endregion