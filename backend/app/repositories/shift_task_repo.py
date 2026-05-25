from datetime import date

from sqlalchemy.orm import Session, joinedload, selectinload

from app.models.shift.shift import Shift
from app.models.shift.shift_participant import ShiftParticipant
from app.models.task.shift_task import ShiftTask
from app.models.task.task import TaskStatusEnum
from app.repositories.generic_repo import BaseRepository

class ShiftTaskRepository(BaseRepository[ShiftTask]):
    def __init__(self, db: Session):
        super().__init__(ShiftTask)
        self.db = db

    def get_by_shift(self, db: Session, shift_id: int) -> list[ShiftTask]:
        return db.query(ShiftTask).filter(ShiftTask.shift_id == shift_id).all()

    def get_by_animal(self, db: Session, animal_id: int) -> list[ShiftTask]:
        return db.query(ShiftTask).filter(ShiftTask.animal_id == animal_id).all()

    def update_status(self, db: Session, shift_task_id: int, status: TaskStatusEnum) -> ShiftTask | None:
        shift_task = self.get_by_id(db, shift_task_id)
        if shift_task:
            shift_task.status = status
            db.commit()
            db.refresh(shift_task)
        return shift_task

    def assign_participant(self, db: Session, shift_task_id: int, participant_id: int) -> ShiftTask | None:
        shift_task = self.get_by_id(db, shift_task_id)
        if shift_task:
            shift_task.participant_id = participant_id
            db.commit()
            db.refresh(shift_task)
        return shift_task

    def unassign_participant(self, db: Session, shift_task_id: int) -> ShiftTask | None:
        shift_task = self.get_by_id(db, shift_task_id)
        if shift_task:
            shift_task.participant_id = None
            db.commit()
            db.refresh(shift_task)
        return shift_task

    def get_by_member(
            self,
            db: Session,
            member_id: int,
            from_date: date = None
    ) -> list[type[ShiftTask]]:

        query = (
            db.query(ShiftTask)
            .join(ShiftParticipant, ShiftTask.participant_id == ShiftParticipant.id)
            .join(Shift, ShiftTask.shift_id == Shift.id)
            .filter(ShiftParticipant.member_id == member_id)
        )

        #ignore past shifts
        if from_date:
            query = query.filter(Shift.day >= from_date)

        return (
            query.options(
                selectinload(ShiftTask.shift),
                selectinload(ShiftTask.task),
                selectinload(ShiftTask.animal),
                selectinload(ShiftTask.participant)
            )
            .all()
        )
