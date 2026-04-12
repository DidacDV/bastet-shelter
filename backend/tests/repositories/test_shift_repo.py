from datetime import datetime, date
from app.repositories.shift_repo import ShiftRepository
from app.models.shift.shift import Shift
from app.models.refuge import Refuge
from tests.repositories.utils import _create_shelter

class TestShiftRepository:
    repo = ShiftRepository(None)

    def test_get_by_refuge(self, db):
        shelter = _create_shelter(db)
        refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
        db.add(refuge)
        db.commit()
        db.refresh(refuge)

        shift = Shift(
            start_time=datetime(2023, 10, 10, 8, 0),
            end_time=datetime(2023, 10, 10, 12, 0),
            day=date(2023, 10, 10),
            shelter_id=shelter.id,
            refuge_id=refuge.id
        )
        db.add(shift)
        db.commit()

        result = self.repo.get_by_refuge(db, refuge.id)
        assert len(result) == 1
        assert result[0].refuge_id == refuge.id

    def test_get_by_date(self, db):
        shelter = _create_shelter(db)
        refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
        db.add(refuge)
        db.commit()
        db.refresh(refuge)

        day = date(2023, 10, 11)
        shift = Shift(
            start_time=datetime(2023, 10, 11, 8, 0),
            end_time=datetime(2023, 10, 11, 12, 0),
            day=day,
            shelter_id=shelter.id,
            refuge_id=refuge.id
        )
        db.add(shift)
        db.commit()

        result = self.repo.get_by_date(db, day)
        assert len(result) == 1
        assert result[0].day == day

    def test_get_by_id(self, db):
        shelter = _create_shelter(db)
        refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
        db.add(refuge)
        db.commit()
        db.refresh(refuge)

        shift = Shift(
            start_time=datetime(2023, 10, 12, 8, 0),
            end_time=datetime(2023, 10, 12, 12, 0),
            day=date(2023, 10, 12),
            shelter_id=shelter.id,
            refuge_id=refuge.id
        )
        db.add(shift)
        db.commit()
        db.refresh(shift)

        result = self.repo.get_by_id(db, shift.id)
        assert result is not None
        assert result.id == shift.id

    def test_delete(self, db):
        shelter = _create_shelter(db)
        refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
        db.add(refuge)
        db.commit()
        db.refresh(refuge)

        shift = Shift(
            start_time=datetime(2023, 10, 12, 8, 0),
            end_time=datetime(2023, 10, 12, 12, 0),
            day=date(2023, 10, 12),
            shelter_id=shelter.id,
            refuge_id=refuge.id
        )
        db.add(shift)
        db.commit()
        db.refresh(shift)

        self.repo.delete(db, shift.id)
        assert self.repo.get_by_id(db, shift.id) is None
