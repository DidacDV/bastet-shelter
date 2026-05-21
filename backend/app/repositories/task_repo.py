from sqlalchemy.orm import Session
from app.models.task.task import Task
from app.models.task.shift_task import ShiftTask
from app.repositories.generic_repo import BaseRepository

class TaskRepository(BaseRepository[Task]):
    def __init__(self, db: Session):
        super().__init__(Task)
        self.db = db


    def get_by_shelter(self, db: Session, shelter_id: int) -> list[Task]:
        return db.query(Task).filter(Task.shelter_id == shelter_id).all()

    def is_used_in_shift(self, db: Session, task_id: int) -> bool:
        return db.query(ShiftTask.id).filter(ShiftTask.task_id == task_id).first() is not None
