
from app.repositories.shelter_repo import ShelterRepository
from tests.repositories.utils import _create_shelter


class TestShelterRepository:
    repo = ShelterRepository()

    def test_create_and_get(self, db):
        shelter = _create_shelter(db)
        assert shelter.id is not None
        assert shelter.name == "Rodamons"

    def test_get_by_volunteer_code(self, db):
        _create_shelter(db, volunteer_code="VOL999")
        result = self.repo.get_by_volunteer_code(db, "VOL999")
        assert result is not None
        assert result.volunteer_code == "VOL999"

    def test_get_by_volunteer_code_not_found(self, db):
        result = self.repo.get_by_volunteer_code(db, "INVALID")
        assert result is None

    def test_get_by_manager_code(self, db):
        _create_shelter(db, manager_code="MAN999")
        result = self.repo.get_by_manager_code(db, "MAN999")
        assert result is not None
        assert result.manager_code == "MAN999"

    def test_get_by_manager_code_not_found(self, db):
        result = self.repo.get_by_manager_code(db, "INVALID")
        assert result is None

    def test_volunteer_code_does_not_match_manager_code(self, db):
        _create_shelter(db, volunteer_code="VOL123", manager_code="MAN456")
        assert self.repo.get_by_volunteer_code(db, "MAN456") is None
        assert self.repo.get_by_manager_code(db, "VOL123") is None
