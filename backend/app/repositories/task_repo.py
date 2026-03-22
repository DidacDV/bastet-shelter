from sqlalchemy.orm import Session
from app.models.task.task import Task
from app.repositories.generic_repo import BaseRepository

class TaskRepository(BaseRepository[Task]):
    def __init__(self):
        super().__init__(Task)

    def get_by_shelter(self, db: Session, shelter_id: int) -> list[Task]:
        return db.query(Task).filter(Task.shelter_id == shelter_id).all()
