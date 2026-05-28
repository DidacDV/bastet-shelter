from datetime import datetime, date
from app.repositories.shift_task_repo import ShiftTaskRepository
from app.models.shift.shift import Shift
from app.models.shift.shift_participant import ShiftParticipant
from app.models.task.shift_task import ShiftTask
from app.models.task.task import Task, TaskStatusEnum
from app.models.refuge import Refuge
from app.models.animal.animal import Animal, AnimalTypeEnum
from app.models.shelter_member import Volunteer, RoleEnum
from tests.repositories.utils import _create_shelter, _create_user

class TestShiftTaskRepository:
    repo = ShiftTaskRepository(None)

    def _setup_shift(self, db):
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

        task = Task(title="Test Task", description="Desc", num_people=1, shelter_id=shelter.id)
        db.add(task)
        db.commit()
        db.refresh(shift)
        db.refresh(task)
        return shelter, refuge, shift, task

    def test_get_by_shift(self, db):
        _, _, shift, task = self._setup_shift(db)
        shift_task = ShiftTask(shift_id=shift.id, task_id=task.id, assigned_date=shift.day)
        db.add(shift_task)
        db.commit()

        result = self.repo.get_by_shift(db, shift.id)
        assert len(result) == 1
        assert result[0].shift_id == shift.id

    def test_get_by_animal(self, db):
        shelter, refuge, shift, task = self._setup_shift(db)
        animal = Animal(
            name="Test Animal",
            link_name="test-animal",
            birth_date=date(2026, 1, 1),
            description="Desc", 
            breed="Breed", 
            animal_type=AnimalTypeEnum.CAT, 
            refuge_id=refuge.id
        )
        db.add(animal)
        db.commit()
        db.refresh(animal)

        shift_task = ShiftTask(shift_id=shift.id, task_id=task.id, assigned_date=shift.day, animal_id=animal.id)
        db.add(shift_task)
        db.commit()

        result = self.repo.get_by_animal(db, animal.id)
        assert len(result) == 1
        assert result[0].animal_id == animal.id

    def test_update_status(self, db):
        _, _, shift, task = self._setup_shift(db)
        shift_task = ShiftTask(shift_id=shift.id, task_id=task.id, assigned_date=shift.day, status=TaskStatusEnum.NOT_COMPLETED)
        db.add(shift_task)
        db.commit()
        db.refresh(shift_task)

        result = self.repo.update_status(db, shift_task.id, TaskStatusEnum.COMPLETED)
        assert result is not None
        assert result.status == TaskStatusEnum.COMPLETED

        # Not found case
        assert self.repo.update_status(db, 999, TaskStatusEnum.COMPLETED) is None

    def test_assign_participant(self, db):
        shelter, _, shift, task = self._setup_shift(db)
        shift_task = ShiftTask(shift_id=shift.id, task_id=task.id, assigned_date=shift.day)
        db.add(shift_task)
        
        user = _create_user(db)
        volunteer = Volunteer(user_id=user.id, shelter_id=shelter.id, role=RoleEnum.VOLUNTEER)
        db.add(volunteer)
        db.commit()
        db.refresh(volunteer)

        participant = ShiftParticipant(shift_id=shift.id, member_id=volunteer.id)
        db.add(participant)
        db.commit()
        db.refresh(participant)
        db.refresh(shift_task)

        result = self.repo.assign_participant(db, shift_task.id, participant.id)
        assert result is not None
        assert result.participant_id == participant.id

        assert self.repo.assign_participant(db, 999, participant.id) is None
