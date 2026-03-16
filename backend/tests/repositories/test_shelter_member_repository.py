from app.models.shelter_member import RoleEnum
from app.repositories.shelter_member_repo import ShelterMemberRepository
from tests.repositories.utils import _create_shelter, _create_user


class TestShelterMemberRepository:

    def test_create_member(self, db):
        shelter = _create_shelter(db)
        user = _create_user(db)
        repo = ShelterMemberRepository(db)

        member = repo.create_member(user_id=user.id, shelter_id=shelter.id, role=RoleEnum.VOLUNTEER)

        assert member.id is not None
        assert member.user_id == user.id
        assert member.role == RoleEnum.VOLUNTEER

    def test_get_by_user_returns_member(self, db):
        shelter = _create_shelter(db)
        user = _create_user(db)
        repo = ShelterMemberRepository(db)
        repo.create_member(user_id=user.id, shelter_id=shelter.id, role=RoleEnum.MANAGER)

        result = repo.get_by_user(user.id)

        assert result is not None
        assert result.user_id == user.id
        assert result.role == RoleEnum.MANAGER

    def test_get_by_user_loads_shelter(self, db):
        shelter = _create_shelter(db)
        user = _create_user(db)
        repo = ShelterMemberRepository(db)
        repo.create_member(user_id=user.id, shelter_id=shelter.id, role=RoleEnum.VOLUNTEER)

        result = repo.get_by_user(user.id)

        assert result.shelter.name == "Rodamons"

    def test_get_by_user_not_found(self, db):
        repo = ShelterMemberRepository(db)
        result = repo.get_by_user(user_id=9999)
        assert result is None