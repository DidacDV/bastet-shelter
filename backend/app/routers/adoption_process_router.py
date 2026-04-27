from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, require_manager, get_current_adoptant
from app.models.user import AuthenticatedUser
from app.models.adoption.adoptant import Adoptant
from app.schemas.adoption_schema.adoption_form_schema import AdoptionFormSubmit
from app.schemas.adoption_schema.adoption_process_schema import (
    AdoptionProcessResponse,
    RejectionRequest,
    AdoptionProcessDetailResponse, AdoptionProcessResponseList
)
from app.schemas.adoption_schema.adoption_step_schema import AdvanceStepRequest
from app.services.adoption_process_service import AdoptionProcessService
from app.services.adoption_steps_service import AdoptionStepsService

router = APIRouter(prefix="/adoption", tags=["Adoption Process"])


def get_process_service(db: Session = Depends(get_db)) -> AdoptionProcessService:
    return AdoptionProcessService(db)


def get_step_service(db: Session = Depends(get_db)) -> AdoptionStepsService:
    return AdoptionStepsService(db)


# ADOPTANT REGION
@router.post("/start/{animal_id}", response_model=AdoptionProcessResponse, status_code=status.HTTP_201_CREATED)
def start_adoption(
        animal_id: int,
        form_data: AdoptionFormSubmit,
        process_service: AdoptionProcessService = Depends(get_process_service)
):
    # TODO: update with real adoptant when web is functional
    return process_service.start_adoption(animal_id, "dac@dac.com", "dac", form_data)


@router.post("/{process_id}/cancel", status_code=status.HTTP_204_NO_CONTENT)
def cancel_adoption(
        process_id: int,
        adoptant: Adoptant = Depends(get_current_adoptant),
        process_service: AdoptionProcessService = Depends(get_process_service)
):
    process_service.cancel_adoption(process_id, adoptant.id)

# MANAGER REGION
@router.post("/{process_id}/reject", status_code=status.HTTP_204_NO_CONTENT)
def reject_adoption_process(
        process_id: int,
        request: RejectionRequest,
        auth: AuthenticatedUser = Depends(require_manager),
        process_service: AdoptionProcessService = Depends(get_process_service)
):
    process_service.reject_adoption(process_id, auth.shelter_id, request.reason)


@router.get("/shelter", response_model=AdoptionProcessResponseList)
def get_all_processes_for_shelter(
        auth: AuthenticatedUser = Depends(require_manager),
        process_service: AdoptionProcessService = Depends(get_process_service)
):
    return {"processes": process_service.get_all_processes_for_shelter(auth.shelter_id)}


@router.get("/{process_id}/manager", response_model=AdoptionProcessDetailResponse)
def get_adoption_process_manager(
        process_id: int,
        auth: AuthenticatedUser = Depends(require_manager),
        process_service: AdoptionProcessService = Depends(get_process_service)
):
    return process_service.get_adoption_process_steps_manager(process_id, auth.shelter_id)


@router.get("/{process_id}/details", response_model=AdoptionProcessDetailResponse)
def get_adoption_process_details(
        process_id: int,
        auth: AuthenticatedUser = Depends(require_manager),
        process_service: AdoptionProcessService = Depends(get_process_service)
):
    return process_service.get_adoption_process_details(process_id)


# ADOPTION PROCESS ACTIONS REGION
@router.post("/{process_id}/advance", response_model=AdoptionProcessDetailResponse)
def advance_current_step(
        process_id: int,
        request: AdvanceStepRequest,
        auth: AuthenticatedUser = Depends(require_manager),
        process_service: AdoptionProcessService = Depends(get_process_service),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    process_service.check_is_process_active(process_id)
    step_service.advance_current_step(process_id, request)

    if not step_service.has_pending_steps(process_id):
        process_service.mark_process_completed(process_id)

    return process_service.get_adoption_process_steps_manager(process_id, auth.shelter_id)


@router.post("/{process_id}/skip", response_model=AdoptionProcessDetailResponse)
def skip_step(
        process_id: int,
        auth: AuthenticatedUser = Depends(require_manager),
        process_service: AdoptionProcessService = Depends(get_process_service),
        step_service: AdoptionStepsService = Depends(get_step_service)
):
    process_service.check_is_process_active(process_id)
    step_service.skip_step(process_id)

    if not step_service.has_pending_steps(process_id):
        process_service.mark_process_completed(process_id)

    return process_service.get_adoption_process_steps_manager(process_id, auth.shelter_id)

@router.get("/{process_id}/pdf")
def get_process_contract_pdf(
            process_id: int,
            auth: AuthenticatedUser = Depends(require_manager),
            process_service: AdoptionProcessService = Depends(get_process_service),
    ):
    process_service.generate_pdf(process_id, auth.shelter_id)