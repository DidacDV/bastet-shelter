from datetime import date, datetime

from app.repositories.task_repo import TaskRepository
from app.models.task.task import Task
from app.models.task.shift_task import ShiftTask
from app.models.shift.shift import Shift
from app.models.refuge import Refuge
from tests.repositories.utils import _create_shelter

class TestTaskRepository:
    repo = TaskRepository(None)

    def test_get_by_shelter(self, db):
        shelter = _create_shelter(db)
        task = Task(title="Test Task", description="Desc", num_people=1, shelter_id=shelter.id)
        db.add(task)
        db.commit()

        result = self.repo.get_by_shelter(db, shelter.id)
        assert len(result) == 1
        assert result[0].shelter_id == shelter.id

    def test_create(self, db):
        shelter = _create_shelter(db)
        task = Task(title="Created Task", description="Desc", num_people=1, shelter_id=shelter.id)
        result = self.repo.create(db, task)
        assert result.id is not None
        assert result.title == "Created Task"

    def test_get_all(self, db):
        shelter = _create_shelter(db)
        task = Task(title="Test Task", description="Desc", num_people=1, shelter_id=shelter.id)
        db.add(task)
        db.commit()

        result = self.repo.get_all(db)
        assert len(result) >= 1

    def test_is_used_in_shift(self, db):
        shelter = _create_shelter(db)
        refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
        task = Task(title="Test Task", description="Desc", num_people=1, shelter_id=shelter.id)
        unused_task = Task(title="Unused Task", description="Desc", num_people=1, shelter_id=shelter.id)
        db.add_all([refuge, task, unused_task])
        db.commit()
        db.refresh(refuge)
        db.refresh(task)
        db.refresh(unused_task)

        shift = Shift(
            start_time=datetime(2026, 1, 1, 8, 0),
            end_time=datetime(2026, 1, 1, 12, 0),
            day=date(2026, 1, 1),
            shelter_id=shelter.id,
            refuge_id=refuge.id,
        )
        db.add(shift)
        db.commit()
        db.refresh(shift)

        db.add(ShiftTask(shift_id=shift.id, task_id=task.id, assigned_date=shift.day))
        db.commit()

        assert self.repo.is_used_in_shift(db, task.id) is True
        assert self.repo.is_used_in_shift(db, unused_task.id) is False
