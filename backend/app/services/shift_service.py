from datetime import date
from typing import Optional, List
from sqlalchemy.orm import Session

from app.models.shift.shift import Shift
from app.models.shift.shift_participant import ShiftParticipant
from app.models.task.shift_task import ShiftTask
from app.models.task.task import TaskStatusEnum
from app.repositories.shelter_member_repo import ShelterMemberRepository
from app.repositories.shift_repo import ShiftRepository
from app.repositories.shift_participant_repo import ShiftParticipantRepository
from app.repositories.shift_task_repo import ShiftTaskRepository
from app.repositories.task_repo import TaskRepository
from app.repositories.animal_repo import AnimalRepository
from app.repositories.refuge_repo import RefugeRepository
from app.schemas.shift_schema.shift_schema import ShiftCreate, ShiftResponse
from app.schemas.shift_schema.shift_participant_schema import ShiftParticipantResponse
from app.schemas.task_schema.shift_task_schema import ShiftTaskResponse

class ShiftService:
    def __init__(self, db: Session):
        self.db = db
        self.member_repo = ShelterMemberRepository(db)
        self.shift_repo = ShiftRepository(db)
        self.participant_repo = ShiftParticipantRepository(db)
        self.shift_task_repo = ShiftTaskRepository(db)
        self.task_repo = TaskRepository(db)
        self.animal_repo = AnimalRepository(db)
        self.refuge_repo = RefugeRepository(db)

    def create_shift(self, data: ShiftCreate, refuge_id: int, shelter_id: int) -> ShiftResponse:
        """Creates shift for a refuge linked to a shelter"""
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge or refuge.shelter_id != shelter_id:
            raise ValueError("Refuge not found or does not belong to this shelter")
            
        new_shift = Shift(**data.model_dump(), refuge_id=refuge_id, shelter_id=shelter_id)
        created_shift = self.shift_repo.create(self.db, new_shift)
        return ShiftResponse.model_validate(created_shift)

    def get_shifts(self, refuge_id: int, day: Optional[date] = None) -> List[ShiftResponse]:
        """List shifts optionally filtered by date"""
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge:
            raise ValueError("Refuge not found")
        shifts = self.shift_repo.get_by_refuge(self.db, refuge_id)
        if day:
            shifts = [s for s in shifts if s.day == day]
        return [ShiftResponse.model_validate(s) for s in shifts]

    def join_shift(self, shift_id: int, user_id: int) -> ShiftParticipantResponse:
        volunteer = self.member_repo.get_by_user(user_id)
        if not volunteer:
            raise ValueError("Volunteer record not found")
        participant = ShiftParticipant(shift_id=shift_id, volunteer_id=volunteer.id)
        created_participant = self.participant_repo.create(self.db, participant)
        return ShiftParticipantResponse.model_validate(created_participant)

    def leave_shift(self, shift_id: int, user_id: int) -> None:
        volunteer = self.member_repo.get_by_user(user_id)
        if not volunteer:
            raise ValueError("Volunteer record not found")
        participants = self.participant_repo.get_by_shift(self.db, shift_id)
        participant = next((p for p in participants if p.volunteer_id == volunteer.id), None)
        if participant:
            self.participant_repo.delete(self.db, participant.id)

    def add_task_to_shift(self, shift_id: int, task_id: int, animal_id: Optional[int] = None) -> ShiftTaskResponse:
        """optionally linked to an animal"""
        shift = self.shift_repo.get_by_id(self.db, shift_id)
        if not shift:
            raise ValueError("Shift not found")
        
        task = self.task_repo.get_by_id(self.db, task_id)
        if not task:
            raise ValueError("Task template not found")

        if animal_id:
            animal = self.animal_repo.get_by_id(self.db, animal_id)
            if not animal:
                raise ValueError("Animal not found")

        shift_task = ShiftTask(
            shift_id=shift_id,
            task_id=task_id,
            animal_id=animal_id,
            assigned_date=shift.day,
            status=TaskStatusEnum.NOT_COMPLETED
        )
        created_shift_task = self.shift_task_repo.create(self.db, shift_task)
        return ShiftTaskResponse.model_validate(created_shift_task)

    def assign_task(self, shift_task_id: int, participant_id: int) -> ShiftTaskResponse:
        """Assigns a ShiftTask to a participant"""
        updated_task = self.shift_task_repo.assign_participant(self.db, shift_task_id, participant_id)
        if not updated_task:
            raise ValueError("ShiftTask not found")
        return ShiftTaskResponse.model_validate(updated_task)

    def complete_task(self, shift_task_id: int) -> ShiftTaskResponse:
        """Updates status to COMPLETED"""
        updated_task = self.shift_task_repo.update_status(self.db, shift_task_id, TaskStatusEnum.COMPLETED)
        if not updated_task:
            raise ValueError("ShiftTask not found")
        return ShiftTaskResponse.model_validate(updated_task)
