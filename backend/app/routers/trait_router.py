from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.trait_schema import TraitCreate, TraitResponse
from app.services.trait_service import TraitService

router = APIRouter(prefix="/traits", tags=["traits"])


def get_trait_service(db: Session = Depends(get_db)) -> TraitService:
    return TraitService(db)


@router.post("/", response_model=TraitResponse)
def add_trait(
    data: TraitCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: TraitService = Depends(get_trait_service)
):
    try:
        return service.add_trait(data, auth.shelter_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.patch("/{trait_id}", response_model=TraitResponse)
def edit_trait(
    trait_id: int,
    data: TraitCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: TraitService = Depends(get_trait_service)
):
    try:
        return service.edit_trait(trait_id, data, auth.shelter_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.delete("/{trait_id}", status_code=204)
def delete_trait(
    trait_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: TraitService = Depends(get_trait_service)
):
    try:
        service.delete_trait(trait_id, auth.shelter_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
