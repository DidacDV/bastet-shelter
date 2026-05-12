from datetime import date
from typing import Optional, List

from sqlalchemy.orm import Session, InstrumentedAttribute

from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError
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
from app.schemas.animals_schema.animals_schema import AnimalShortInfo
from app.schemas.shift_schema.shift_schema import ShiftCreate, ShiftResponse, ShiftDetailResponse, ShiftUpdate
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
        self._verify_refuge_access(refuge_id, shelter_id)

        shift_data = data.model_dump(exclude={"task_ids"})
        new_shift = Shift(**shift_data, refuge_id=refuge_id, shelter_id=shelter_id)
        created_shift = self.shift_repo.create(self.db, new_shift)

        for task_id in data.task_ids:
            self._verify_task_access(task_id, shelter_id)
            shift_task = ShiftTask(
                shift_id=created_shift.id,
                task_id=task_id,
                animal_id=None,
                assigned_date=data.day,
                status=TaskStatusEnum.NOT_COMPLETED,
            )
            self.db.add(shift_task)

        self.db.commit()
        self.db.refresh(created_shift)
        return ShiftResponse.model_validate(created_shift)

    def get_shifts(
        self,
        refuge_id: int,
        day: Optional[date] = None,
        week_start: Optional[date] = None,
    ) -> List[ShiftResponse]:
        """List shifts optionally filtered by date or a 7-day week"""
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge:
            raise NotFoundError("Refuge not found")

        if week_start:
            if week_start.weekday() != 0:
                raise BusinessLogicError("week_start must be a Monday")
            shifts = self.shift_repo.get_by_refuge_and_week(self.db, refuge_id, week_start)
        else:
            shifts = self.shift_repo.get_by_refuge(self.db, refuge_id)
            if day:
                shifts = [s for s in shifts if s.day == day]

        return [ShiftResponse.model_validate(s) for s in shifts]

    def get_shift_detail(self, shift_id: int, shelter_id: int) -> ShiftDetailResponse:
        shift = self.shift_repo.get_detail_with_relations(self.db, shift_id)

        if not shift:
            raise NotFoundError("Shift not found")
        if shift.shelter_id != shelter_id:
            raise AuthorizationError("Shift does not belong to this shelter")

        return ShiftDetailResponse.model_validate(shift)

    def delete_shift(self, shift_id: int, shelter_id: int) -> None:
        shift = self._get_shift_or_raise(shift_id)
        if shift.shelter_id != shelter_id:
            raise AuthorizationError("Shift does not belong to this shelter")
        self.shift_repo.delete_shift(self.db, shift)

    def clear_day(self, refuge_id: int, shelter_id: int, day: date) -> int:
        self._verify_refuge_access(refuge_id, shelter_id)
        return self.shift_repo.delete_by_refuge_and_day(self.db, refuge_id, day)

    def clear_week(self, refuge_id: int, shelter_id: int, week_start: date) -> int:
        self._verify_refuge_access(refuge_id, shelter_id)
        return self.shift_repo.delete_by_refuge_and_week(self.db, refuge_id, week_start)

    def join_shift(self, shift_id: int, user_id: int) -> ShiftParticipantResponse:
        shift = self._get_shift_or_raise(shift_id)

        if shift.max_participants is not None and shift.current_participants >= shift.max_participants:
            raise BusinessLogicError("This shift has reached its maximum capacity.")

        member = self.member_repo.get_by_user(user_id)
        if not member:
            raise NotFoundError("Member record not found")
        participant = ShiftParticipant(shift_id=shift_id, member_id=member.id)
        created_participant = self.participant_repo.create(self.db, participant)
        return ShiftParticipantResponse.model_validate(created_participant)

    def leave_shift(self, shift_id: int, user_id: int) -> None:
        volunteer = self._get_volunteer_or_raise(user_id)
        participants = self.participant_repo.get_by_shift(self.db, shift_id)
        participant = next((p for p in participants if p.member_id == volunteer.id), None)

        if participant:
            for task in participant.shift_tasks:
                task.participant_id = None
                task.status = TaskStatusEnum.NOT_COMPLETED

            self.db.commit()

            self.participant_repo.delete(self.db, participant.id)

    def add_task_to_shift(
        self,
        shift_id: int,
        task_id: int,
        shelter_id: int,
        animal_id: Optional[int] = None,
    ) -> ShiftTaskResponse:
        """adds a task template to a shift, optionally linked to an animal."""
        shift = self._get_shift_or_raise(shift_id)
        if shift.shelter_id != shelter_id:
            raise AuthorizationError("Shift does not belong to this shelter")

        self._verify_task_access(task_id, shelter_id)

        if animal_id:
            animal = self.animal_repo.get_by_id(self.db, animal_id)
            if not animal:
                raise NotFoundError("Animal not found")

        shift_task = ShiftTask(
            shift_id=shift_id,
            task_id=task_id,
            animal_id=animal_id,
            assigned_date=shift.day,
            status=TaskStatusEnum.NOT_COMPLETED,
        )
        created_shift_task = self.shift_task_repo.create(self.db, shift_task)
        return ShiftTaskResponse.model_validate(created_shift_task)

    def remove_task_from_shift(self, shift_task_id: int, shelter_id: int) -> None:
        """removes a task from a shift. Guards shelter ownership"""
        shift_task = self._get_shift_task_or_raise(shift_task_id)
        shift = self._get_shift_or_raise(shift_task.shift_id)
        if shift.shelter_id != shelter_id:
            raise AuthorizationError("Shift does not belong to this shelter")
        self.shift_task_repo.delete(self.db, shift_task_id)

    def assign_task(
        self, shift_task_id: int, participant_id: int, shelter_id: int
    ) -> ShiftTaskResponse:
        """assigns a ShiftTask to a participant"""
        shift_task = self._get_shift_task_or_raise(shift_task_id)
        shift = self._get_shift_or_raise(shift_task.shift_id)
        if shift.shelter_id != shelter_id:
            raise AuthorizationError("Shift does not belong to this shelter")

        participant = self.participant_repo.get_by_id(self.db, participant_id)
        if not participant:
            raise NotFoundError("Participant not found")
        if participant.shift_id != shift.id:
            raise BusinessLogicError("Participant is not assigned to this shift")

        updated_task = self.shift_task_repo.assign_participant(self.db, shift_task_id, participant_id)
        return ShiftTaskResponse.model_validate(updated_task)

    def complete_task(self, shift_task_id: int, user_id: int) -> ShiftTaskResponse:
        """marks a ShiftTask as COMPLETED"""
        shift_task = self._get_shift_task_or_raise(shift_task_id)
        volunteer = self._get_volunteer_or_raise(user_id)

        if shift_task.participant_id != volunteer.id:
            raise AuthorizationError("You are not assigned to this task")

        updated_task = self.shift_task_repo.update_status(
            self.db, shift_task_id, TaskStatusEnum.COMPLETED
        )
        return ShiftTaskResponse.model_validate(updated_task)

    def uncomplete_task(self, shift_task_id: int, user_id: int) -> ShiftTaskResponse:
        """reverts a ShiftTask back to NOT_COMPLETED"""
        shift_task = self._get_shift_task_or_raise(shift_task_id)
        volunteer = self._get_volunteer_or_raise(user_id)

        if shift_task.participant_id != volunteer.id:
            raise AuthorizationError("You are not assigned to this task")

        updated_task = self.shift_task_repo.update_status(
            self.db, shift_task_id, TaskStatusEnum.NOT_COMPLETED
        )
        return ShiftTaskResponse.model_validate(updated_task)


    def copy_shifts_week_without_task(
        self,
        refuge_id: int,
        shelter_id: int,
        source_week_start: date,
        target_week_start: date,
    ) -> list[ShiftResponse]:
        """
        Copies all shifts from source_week into target_week for a given refuge.
        Preserves time slots (start_time, end_time) but moves each shift's day
        forward or backwards by the difference between the two week starts.
        Days that already have shifts are skipped.
        Tasks are not copied
        """
        if source_week_start.weekday() != 0:
            raise BusinessLogicError("week_start must be a Monday")

        self._verify_refuge_access(refuge_id, shelter_id)
        source_shifts = self._get_source_shifts(refuge_id, source_week_start)
        existing_days = self._get_existing_target_days(refuge_id, target_week_start)
        day_diff = target_week_start - source_week_start

        return self._create_copied_shifts(
            source_shifts=source_shifts,
            existing_days=existing_days,
            day_diff=day_diff,
            refuge_id=refuge_id,
            shelter_id=shelter_id,
        )

    def update_shift(self, shift_id: int, shelter_id: int, data: ShiftUpdate) -> ShiftDetailResponse:
        shift = self._get_shift_or_raise(shift_id)

        if shift.shelter_id != shelter_id:
            raise AuthorizationError("Shift does not belong to this shelter")

        if data.refuge_id is not None and data.refuge_id != shift.refuge_id:
            self._verify_refuge_access(data.refuge_id, shelter_id)

        update_data = data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(shift, key, value)

        self.db.commit()

        return self.get_shift_detail(shift_id, shelter_id)

    def _verify_refuge_access(self, refuge_id: int, shelter_id: int) -> None:
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge:
            raise NotFoundError("Refuge not found")
        if refuge.shelter_id != shelter_id:
            raise AuthorizationError("Refuge does not belong to this shelter")

    def _verify_task_access(self, task_id: int, shelter_id: int) -> None:
        """checks that a task template belongs to the shelter"""
        task = self.task_repo.get_by_id(self.db, task_id)
        if not task:
            raise NotFoundError(f"Task {task_id} not found")
        if task.shelter_id != shelter_id:
            raise AuthorizationError(f"Task {task_id} does not belong to this shelter")

    def _get_shift_or_raise(self, shift_id: int) -> Shift:
        shift = self.shift_repo.get_by_id(self.db, shift_id)
        if not shift:
            raise NotFoundError("Shift not found")
        return shift

    def _get_shift_task_or_raise(self, shift_task_id: int) -> ShiftTask:
        shift_task = self.shift_task_repo.get_by_id(self.db, shift_task_id)
        if not shift_task:
            raise NotFoundError("ShiftTask not found")
        return shift_task

    def _get_volunteer_or_raise(self, user_id: int):
        volunteer = self.member_repo.get_by_user(user_id)
        if not volunteer:
            raise NotFoundError("Volunteer record not found")
        return volunteer

    def _get_source_shifts(self, refuge_id: int, source_week_start: date):
        source_shifts = self.shift_repo.get_by_refuge_and_week(self.db, refuge_id, source_week_start)
        if not source_shifts:
            raise NotFoundError("No shifts found in the source week to copy from")
        return source_shifts

    def _get_existing_target_days(self, refuge_id: int, target_week_start: date) -> set[date]:
        existing_target = self.shift_repo.get_by_refuge_and_week(self.db, refuge_id, target_week_start)
        return {s.day for s in existing_target}

    def _create_copied_shifts(
        self,
        source_shifts: list,
        existing_days: set[date],
        day_diff,
        refuge_id: int,
        shelter_id: int,
    ) -> list[ShiftResponse]:
        created = []
        for shift in source_shifts:
            new_day = shift.day + day_diff
            if new_day in existing_days:
                continue
            new_shift = Shift(
                start_time=shift.start_time + day_diff,
                end_time=shift.end_time + day_diff,
                day=new_day,
                refuge_id=refuge_id,
                shelter_id=shelter_id,
            )
            created_shift = self.shift_repo.create(self.db, new_shift)
            created.append(ShiftResponse.model_validate(created_shift))
        return created