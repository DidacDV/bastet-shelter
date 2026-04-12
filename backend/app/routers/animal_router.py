from typing import List
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.animals_schema.animals_image_schema import AnimalImageResponse
from app.schemas.animals_schema.animals_schema import AnimalCreate, AnimalResponse, AnimalSummaryInfoList, AnimalUpdate
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

@router.get("/short_info", response_model=AnimalSummaryInfoList)
def get_short_infos(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AnimalService = Depends(get_animal_service)
):
    try:
        animals = service.get_all_animals_short_info(auth.shelter_id)
        return {"animals": animals}
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

@router.patch("/{animal_id}", response_model=AnimalResponse)
def update_animal(
    animal_id: int,
    data: AnimalUpdate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AnimalService = Depends(get_animal_service)
):
    try:
        return service.update_animal(animal_id, data, auth.shelter_id)
    except ValueError as e:
        status_code = 404 if "not found" in str(e).lower() else 400
        raise HTTPException(status_code=status_code, detail=str(e))

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


@router.post("/{animal_id}/images", response_model=AnimalImageResponse)
def upload_animal_image(
        animal_id: int,
        file: UploadFile = File(...),
        auth: AuthenticatedUser = Depends(require_manager),
        service: AnimalService = Depends(get_animal_service)
):
    try:
        return service.upload_image(animal_id, file, auth.shelter_id)
    except ValueError as e:
        status_code = 404 if "not found" in str(e).lower() else 400
        raise HTTPException(status_code=status_code, detail=str(e))


@router.delete("/{animal_id}/images/{image_id}", status_code=204)
def delete_animal_image(
        animal_id: int,
        image_id: int,
        auth: AuthenticatedUser = Depends(require_manager),
        service: AnimalService = Depends(get_animal_service)
):
    try:
        service.delete_image(animal_id, image_id, auth.shelter_id)
    except ValueError as e:
        status_code = 404 if "not found" in str(e).lower() else 400
        raise HTTPException(status_code=status_code, detail=str(e))