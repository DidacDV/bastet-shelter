from typing import List, Optional
from datetime import date
from fastapi import APIRouter, Depends, UploadFile, File, BackgroundTasks
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, get_current_user, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.animals_schema.animals_image_schema import AnimalImageResponse
from app.schemas.animals_schema.animals_schema import AnimalCreate, AnimalResponse, AnimalSummaryInfoList, AnimalUpdate, \
    AnimalPublicSummaryList, AnimalPublicDetail
from app.schemas.shift_schema.shift_schema import AnimalPendingTasksResponse
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
    return service.register_animal(data, auth.shelter_id)

@router.get("/", response_model=List[AnimalResponse])
def get_animals(
    refuge_id: int,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AnimalService = Depends(get_animal_service)
):
    return service.get_animals(refuge_id)

@router.get("/short_info", response_model=AnimalSummaryInfoList)
def get_short_infos(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AnimalService = Depends(get_animal_service)
):
    animals = service.get_all_animals_short_info(auth.shelter_id)
    return {"animals": animals}

@router.get("/short_info_portal", response_model=AnimalPublicSummaryList)
def get_short_infos_portal(
    province_id: str,
    service: AnimalService = Depends(get_animal_service)
):
    if not province_id:
        return {"animals": []}
    animals = service.get_portal_animals_short_info(province_id)
    return {"animals": animals}

"""uses link names for both shelter and animal instead of regular ids so it can be integrated to external services of shelters"""
@router.get("/public/by-link/{shelter_link_name}/{animal_link_name}", response_model=AnimalPublicDetail)
def get_animal_public_detail_by_link_name(
    shelter_link_name: str,
    animal_link_name: str,
    service: AnimalService = Depends(get_animal_service)
):
    return service.get_animal_public_detail_by_link_name(shelter_link_name, animal_link_name)

@router.get("/public/{animal_id}", response_model=AnimalPublicDetail)
def get_animal_public_detail(
    animal_id: int,
    service: AnimalService = Depends(get_animal_service)
):
    return service.get_animal_public_detail(animal_id)

@router.get("/{animal_id}/pending-tasks", response_model=AnimalPendingTasksResponse)
def get_animal_pending_tasks(
    animal_id: int,
    day: Optional[date] = None,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AnimalService = Depends(get_animal_service),
):
    return {"pending_tasks": service.get_pending_tasks_for_animal(animal_id, day)}

@router.get("/{animal_id}", response_model=AnimalResponse)
def get_animal_detail(
    animal_id: int,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AnimalService = Depends(get_animal_service)
):
    return service.get_animal_by_id(animal_id)

@router.patch("/{animal_id}", response_model=AnimalResponse)
def update_animal(
    animal_id: int,
    data: AnimalUpdate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AnimalService = Depends(get_animal_service)
):
    return service.update_animal(animal_id, data, auth.shelter_id)

@router.delete("/{animal_id}", status_code=204)
def delete_animal(
    animal_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AnimalService = Depends(get_animal_service)
):
    service.delete_animal(animal_id, auth.shelter_id)

@router.patch("/{animal_id}/adoption", response_model=AnimalResponse)
def toggle_adoption(
    animal_id: int,
    background_tasks: BackgroundTasks,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AnimalService = Depends(get_animal_service)
):
    return service.set_in_adoption(animal_id, background_tasks)

@router.post("/{animal_id}/images", response_model=AnimalImageResponse)
def upload_animal_image(
        animal_id: int,
        file: UploadFile = File(...),
        auth: AuthenticatedUser = Depends(require_manager),
        service: AnimalService = Depends(get_animal_service)
):
    return service.upload_image(animal_id, file, auth.shelter_id)

@router.delete("/{animal_id}/images/{image_id}", status_code=204)
def delete_animal_image(
        animal_id: int,
        image_id: int,
        auth: AuthenticatedUser = Depends(require_manager),
        service: AnimalService = Depends(get_animal_service)
):
    service.delete_image(animal_id, image_id, auth.shelter_id)