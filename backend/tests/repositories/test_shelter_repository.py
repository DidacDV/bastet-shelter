
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

    def test_get_by_email(self, db):
        _create_shelter(db, email="contact@rodamons.com")
        result = self.repo.get_by_email(db, "contact@rodamons.com")
        assert result is not None
        assert result.email == "contact@rodamons.com"

    def test_get_by_email_is_case_insensitive(self, db):
        _create_shelter(db, email="Contact@Rodamons.com")
        result = self.repo.get_by_email(db, "contact@rodamons.com")
        assert result is not None

    def test_volunteer_code_does_not_match_manager_code(self, db):
        _create_shelter(db, volunteer_code="VOL123", manager_code="MAN456")
        assert self.repo.get_by_volunteer_code(db, "MAN456") is None
        assert self.repo.get_by_manager_code(db, "VOL123") is None

    def test_update_volunteer_code(self, db):
        shelter = _create_shelter(db)
        self.repo.update_volunteer_code(db, shelter.id, "DACDAC11")
        db.refresh(shelter)
        assert shelter.volunteer_code == "DACDAC11"
        assert shelter.manager_code == "MAN456"  # unchanged

    def test_update_manager_code(self, db):
        shelter = _create_shelter(db)
        self.repo.update_manager_code(db, shelter.id, "DACDAC11")
        db.refresh(shelter)
        assert shelter.manager_code == "DACDAC11"
        assert shelter.volunteer_code == "VOL123"  # unchanged

    def test_update_generic(self, db):
        shelter = _create_shelter(db)
        updated = self.repo.update(db, shelter.id, {"name": "New Name", "province_id": "08"})
        assert updated is not None
        assert updated.name == "New Name"
        assert updated.province_id == "08"
        # Verify in DB
        db.refresh(shelter)
        assert shelter.name == "New Name"
        assert shelter.province_id == "08"