from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, require_manager, get_current_adoptant
from app.models.adoption.adoptant import Adoptant
from app.models.user import AuthenticatedUser
from app.schemas.adoption_schema.adoption_form_schema import AdoptionFormResponse
from app.schemas.adoption_schema.adoption_schema import ScheduledDateUpdate, NotesUpdate, ActualPickUpDateUpdate
from app.schemas.adoption_schema.adoption_step_schema import InterviewResponse, ShelterVisitResponse, \
    AdoptionStepResponse, AnimalPickupResponse, ContractResponse

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

@router.patch("/pickup", response_model=AnimalPickupResponse)
def set_animal_pickup_scheduled_date(
        process_id: int,
        data: ScheduledDateUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.set_animal_pickup_scheduled_date(process_id, data)

@router.patch("/{step_id}/actual-pickup", response_model=AnimalPickupResponse)
def set_actual_pickup_date(
    process_id: int,
    step_id: int,
    data: ScheduledDateUpdate,
    auth: AuthenticatedUser = Depends(require_manager),
    step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.set_animal_pickup_actual_date(process_id, step_id, data)

@router.patch("/{step_id}/notes", response_model=AdoptionStepResponse)
def add_notes(
        process_id: int,
        step_id: int,
        data: NotesUpdate,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.add_notes(process_id, step_id, notes= data)

@router.patch("/contract/adoptant-signature", response_model=ContractResponse)
def update_adoptant_signature(
        process_id: int,
        adoptant: Adoptant = Depends(get_current_adoptant),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.update_adoptant_signature(process_id, adoptant.id)

@router.patch("/contract/shelter-signature", response_model=ContractResponse)
def update_shelter_signature(
        process_id: int,
        auth: AuthenticatedUser = Depends(require_manager),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    return step_service.update_shelter_signature(process_id)