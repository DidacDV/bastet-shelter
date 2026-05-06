from datetime import date
from typing import List, Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, get_current_user, require_manager, require_volunteer
from app.models.user import AuthenticatedUser
from app.schemas.shift_schema.shift_schema import ShiftCreate, ShiftResponse
from app.schemas.shift_schema.shift_participant_schema import ShiftParticipantResponse
from app.schemas.task_schema.shift_task_schema import ShiftTaskResponse
from app.services.shift_service import ShiftService

router = APIRouter(prefix="/shifts", tags=["shifts"])

def get_shift_service(db: Session = Depends(get_db)) -> ShiftService:
    return ShiftService(db)

@router.post("/", response_model=ShiftResponse)
def create_shift(
    data: ShiftCreate,
    refuge_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: ShiftService = Depends(get_shift_service)
):
    return service.create_shift(data, refuge_id, auth.shelter_id)

@router.get("/", response_model=List[ShiftResponse])
def get_shifts(
    refuge_id: int,
    day: Optional[date] = None,
    week_start: Optional[date] = None,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: ShiftService = Depends(get_shift_service)
):
    return service.get_shifts(refuge_id, day, week_start)

@router.post("/{shift_id}/join", response_model=ShiftParticipantResponse)
def join_shift(
    shift_id: int,
    auth: AuthenticatedUser = Depends(require_volunteer),
    service: ShiftService = Depends(get_shift_service)
):
    return service.join_shift(shift_id, auth.user.id)

@router.delete("/{shift_id}/leave")
def leave_shift(
    shift_id: int,
    auth: AuthenticatedUser = Depends(require_volunteer),
    service: ShiftService = Depends(get_shift_service)
):
    service.leave_shift(shift_id, auth.user.id)
    return {"message": "Left shift successfully"}

@router.post("/{shift_id}/tasks", response_model=ShiftTaskResponse)
def add_task_to_shift(
    shift_id: int,
    task_id: int,
    animal_id: Optional[int] = None,
    auth: AuthenticatedUser = Depends(require_manager),
    service: ShiftService = Depends(get_shift_service)
):
    return service.add_task_to_shift(shift_id, task_id, animal_id)

@router.patch("/tasks/{shift_task_id}/assign", response_model=ShiftTaskResponse)
def assign_task(
    shift_task_id: int,
    participant_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: ShiftService = Depends(get_shift_service)
):
    return service.assign_task(shift_task_id, participant_id)

@router.patch("/tasks/{shift_task_id}/complete", response_model=ShiftTaskResponse)
def complete_task(
    shift_task_id: int,
    auth: AuthenticatedUser = Depends(require_volunteer),
    service: ShiftService = Depends(get_shift_service)
):
    return service.complete_task(shift_task_id)

@router.post("/copy-week", response_model=list[ShiftResponse])
def copy_week(
    refuge_id: int,
    source_week_start: date,
    target_week_start: date,
    auth: AuthenticatedUser = Depends(require_manager),
    service: ShiftService = Depends(get_shift_service),
):
    return service.copy_shifts_week_without_task(
        refuge_id=refuge_id,
        shelter_id=auth.shelter_id,
        source_week_start=source_week_start,
        target_week_start=target_week_start,
    )