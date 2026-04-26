from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.adoption_schema.adoption_form_schema import AdoptionFormResponse
from app.schemas.adoption_schema.adoption_schema import ScheduledDateUpdate, NotesUpdate
from app.schemas.adoption_schema.adoption_step_schema import InterviewResponse, ShelterVisitResponse, \
    AdoptionStepResponse
from app.schemas.animals_schema.animals_schema import AnimalResponse

from app.services.adoption_steps_service import AdoptionStepsService

router = APIRouter(prefix="/adoption/{process_id}/steps", tags=["Adoption steps"])

def get_step_service(db: Session = Depends(get_db)) -> AdoptionStepsService:
    return AdoptionStepsService(db)

@router.get("/form", response_model=AdoptionFormResponse)
def get_form_details(
        process_id: int,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.get_form_details(process_id)

@router.patch("/interview", response_model=InterviewResponse)
def set_interview_date(
        process_id: int,
        data: ScheduledDateUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.set_interview_scheduled_date(process_id, data)

@router.patch("/shelter-visit", response_model=ShelterVisitResponse)
def set_shelter_visit_date(
        process_id: int,
        data: ScheduledDateUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.set_shelter_visit_scheduled_date(process_id, data)

@router.patch("/pickup", response_model=AnimalResponse)
def set_animal_pickup_scheduled_date(
        process_id: int,
        data: ScheduledDateUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.set_animal_pickup_scheduled_date(process_id, data)

@router.patch("/{step_id}/notes", response_model=AdoptionStepResponse)
def add_notes(
        process_id: int,
        step_id: int,
        data: NotesUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.add_notes(process_id, step_id, notes= data)