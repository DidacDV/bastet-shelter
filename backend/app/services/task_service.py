from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError, AuthorizationError
from app.models.task.task import Task
from app.repositories.task_repo import TaskRepository
from app.schemas.task_schema.task_schema import TaskCreate, TaskResponse, TaskUpdate


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

    def delete_task(self, shelter_id: int, task_id: int) -> None:
        task = self.task_repo.get_by_id(self.db, task_id)
        if not task:
            raise NotFoundError("Task not found")
        if task.shelter_id != shelter_id:
            raise AuthorizationError("Task does not belong to this shelter")

        self.task_repo.delete(self.db, task_id)

    def update_task(self, shelter_id: int, task_id: int, data: TaskUpdate) -> TaskResponse:
        task = self.task_repo.get_by_id(self.db, task_id)
        if not task:
            raise NotFoundError("Task not found")
        if task.shelter_id != shelter_id:
            raise AuthorizationError("Task does not belong to this shelter")

        updated_task = self.task_repo.update(self.db, task_id, data.model_dump())
        return TaskResponse.model_validate(updated_task)