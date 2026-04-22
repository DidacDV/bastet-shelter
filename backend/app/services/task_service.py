from sqlalchemy.orm import Session
from app.models.task.task import Task
from app.repositories.task_repo import TaskRepository
from app.schemas.task_schema.task_schema import TaskCreate, TaskResponse

class TaskService:
    def __init__(self, db: Session):
        self.db = db
        self.task_repo = TaskRepository(db)

    def create_task(self, data: TaskCreate, shelter_id: int) -> TaskResponse:
        """Creates a reusable task template"""
        new_task = Task(**data.model_dump(), shelter_id=shelter_id)
        created_task = self.task_repo.create(self.db, new_task)
        return TaskResponse.model_validate(created_task)

    def get_tasks(self, shelter_id: int) -> list[TaskResponse]:
        """All tasks for a shelter"""
        tasks = self.task_repo.get_by_shelter(self.db, shelter_id)
        return [TaskResponse.model_validate(t) for t in tasks]