from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.task_schema.task_schema import TaskCreate, TaskResponse
from app.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["tasks"])

def get_task_service(db: Session = Depends(get_db)) -> TaskService:
    return TaskService(db)


@router.post("/", response_model=TaskResponse)
def create_task(
    data: TaskCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: TaskService = Depends(get_task_service)
):
    return service.create_task(data, auth.shelter_id)

@router.get("/", response_model=List[TaskResponse])
def get_tasks(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: TaskService = Depends(get_task_service)
):
    return service.get_tasks(auth.shelter_id)
