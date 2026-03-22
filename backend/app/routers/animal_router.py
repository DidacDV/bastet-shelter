from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.animals_schema import AnimalCreate, AnimalResponse
from app.services.animal_service import AnimalService

router = APIRouter(prefix="/animals", tags=["animals"])

def get_animal_service(db: Session = Depends(get_db)) -> AnimalService:
    return AnimalService(db)


@router.post("/", response_model=AnimalResponse)
def register_animal(
    data: AnimalCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AnimalService = Depends(get_animal_service)
):
    try:
        return service.register_animal(data, auth.shelter_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=List[AnimalResponse])
def get_animals(
    refuge_id: int,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AnimalService = Depends(get_animal_service)
):
    try:
        return service.get_animals(refuge_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.get("/{animal_id}", response_model=AnimalResponse)
def get_animal_detail(
    animal_id: int,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AnimalService = Depends(get_animal_service)
):
    try:
        return service.get_animal_by_id(animal_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.patch("/{animal_id}/adoption", response_model=AnimalResponse)
def toggle_adoption(
    animal_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AnimalService = Depends(get_animal_service)
):
    try:
        return service.set_in_adoption(animal_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
