from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, require_manager, get_current_user
from app.models.user import AuthenticatedUser
from app.schemas.trait_schema import TraitCreate, TraitResponse, TraitResponseList
from app.services.trait_service import TraitService

router = APIRouter(prefix="/traits", tags=["traits"])


def get_trait_service(db: Session = Depends(get_db)) -> TraitService:
    return TraitService(db)


@router.get("/", response_model=TraitResponseList)
def get_traits(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: TraitService = Depends(get_trait_service)
):
    return {"traits": service.get_traits(auth.shelter_id)}


@router.post("/", response_model=TraitResponse)
def add_trait(
    data: TraitCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: TraitService = Depends(get_trait_service)
):
    return service.add_trait(data, auth.shelter_id)


@router.put("/{trait_id}", response_model=TraitResponse)
def edit_trait(
    trait_id: int,
    data: TraitCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: TraitService = Depends(get_trait_service)
):
    return service.edit_trait(trait_id, data, auth.shelter_id)


@router.delete("/{trait_id}", status_code=204)
def delete_trait(
    trait_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: TraitService = Depends(get_trait_service)
):
    service.delete_trait(trait_id, auth.shelter_id)