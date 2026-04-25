from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, require_manager, get_current_adoptant
from app.core.exceptions import NotFoundError, AuthorizationError
from app.models.adoption.adoptant import Adoptant
from app.models.user import AuthenticatedUser
from app.schemas.adoption_schema.adoptant_schema import AdoptantResponse
from app.schemas.adoption_schema.adoption_process_schema import AdoptionProcessResponse
from app.services.adoption_process_service import AdoptionProcessService

router = APIRouter(prefix="/adoptant", tags=["Adoptants"])


def get_process_service(db: Session = Depends(get_db)) -> AdoptionProcessService:
    return AdoptionProcessService(db)

@router.get("/processes", response_model=List[AdoptionProcessResponse])
def get_all_processes_for_adoptant(
        adoptant: Adoptant = Depends(get_current_adoptant),
        process_service: AdoptionProcessService = Depends(get_process_service)
):
    return process_service.get_all_processes_for_adoptant(adoptant.id)

@router.get("/processes/{process_id}", response_model=AdoptionProcessResponse)
def get_adoption_process_adoptant(
        process_id: int,
        adoptant: Adoptant = Depends(get_current_adoptant),
        process_service: AdoptionProcessService = Depends(get_process_service)
):
    return process_service.get_adoption_process_steps_adoptant(process_id, adoptant.id)

@router.get("/{adoptant_id}", response_model=AdoptantResponse)
def get_adoptant(
    adoptant_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    process_service: AdoptionProcessService = Depends(get_process_service)
):
    try:
        return process_service.get_adoptant(adoptant_id, auth.shelter_id)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except AuthorizationError as e:
        raise HTTPException(status_code=403, detail=str(e))