from multiprocessing import managers

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from starlette import status

from app.core.dependencies.role_dependencies import get_db, get_current_user, require_manager, require_shelter_manager
from app.models.user import AuthenticatedUser
from app.schemas.shift_schema.shift_schema import ListMyShiftTaskGroupResponse
from app.schemas.task_schema.task_schema import TaskCreate, TaskResponse, TaskResponseList, TaskUpdate
from app.services.shift_service import ShiftService
from app.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["tasks"])

def get_task_service(db: Session = Depends(get_db)) -> TaskService:
    return TaskService(db)

def get_shift_service(db: Session = Depends(get_db)) -> ShiftService:
    return ShiftService(db)

@router.post("/", response_model=TaskResponse)
def create_task(
    data: TaskCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: TaskService = Depends(get_task_service)
):
    return service.create_task(data, auth.shelter_id)

@router.get("/", response_model=TaskResponseList)
def get_tasks(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: TaskService = Depends(get_task_service)
):
    return {"tasks": service.get_tasks(auth.shelter_id)}

@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT,)
def delete_task(
        task_id: int,
        auth: AuthenticatedUser = Depends(require_shelter_manager),
        service: TaskService = Depends(get_task_service)
):
    service.delete_task(auth.shelter_id, task_id)
    return {"message": "Task deleted successfully"}

@router.put("/{task_id}", response_model=TaskResponse, status_code=status.HTTP_200_OK)
def update_shelter(
        task_id: int,
        data: TaskUpdate,
        auth: AuthenticatedUser = Depends(require_shelter_manager),
        service: TaskService = Depends(get_task_service)
):
    return service.update_task(auth.shelter_id, task_id, data)

@router.get("/me", response_model=ListMyShiftTaskGroupResponse)
def get_my_tasks(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: ShiftService = Depends(get_shift_service)
):
    return {"my_shift_tasks":service.get_my_tasks(auth.user.id)}