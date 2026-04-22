from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.adoption_schema.adoption_form_schema import AdoptionFormResponse
from app.schemas.adoption_schema.adoption_schema import ScheduledDateUpdate
from app.schemas.adoption_schema.adoption_step_schema import AdoptionStepDetailResponse

from app.services.adoption_process_service import AdoptionProcessService
from app.services.adoption_steps_service import AdoptionStepsService

router = APIRouter(prefix="/adoption/{process_id}/steps", tags=["Adoption steps"])

def get_process_service(db: Session = Depends(get_db)) -> AdoptionProcessService:
    return AdoptionProcessService(db)

def get_step_service(db: Session = Depends(get_db)) -> AdoptionStepsService:
    return AdoptionStepsService(db)

def handle_service_error(e: ValueError):
    error_msg = str(e).lower()
    status_code = status.HTTP_404_NOT_FOUND if "not found" in error_msg else status.HTTP_400_BAD_REQUEST
    raise HTTPException(status_code=status_code, detail=str(e))

@router.get("/form", response_model=AdoptionFormResponse)
def get_form_details(
        process_id: int,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    try:
        return step_service.get_form_details(process_id)
    except ValueError as e:
        handle_service_error(e)

@router.patch("/interview", response_model=AdoptionStepDetailResponse)
def set_interview_date(
        process_id: int,
        data: ScheduledDateUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    try:
        return step_service.set_interview_scheduled_date(process_id, data)
    except ValueError as e:
        handle_service_error(e)

@router.patch("/shelter-visit", response_model=AdoptionStepDetailResponse)
def set_shelter_visit_date(
        process_id: int,
        data: ScheduledDateUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    try:
        return step_service.set_shelter_visit_scheduled_date(process_id, data)
    except ValueError as e:
        handle_service_error(e)

@router.patch("/pickup", response_model=AdoptionStepDetailResponse)
def set_animal_pickup_scheduled_date(
        process_id: int,
        data: ScheduledDateUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    try:
        return step_service.set_animal_pickup_scheduled_date(process_id, data)
    except ValueError as e:
        handle_service_error(e)