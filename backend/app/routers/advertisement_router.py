from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status, UploadFile, File
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, get_current_user, require_manager
from app.models.user import AuthenticatedUser
from app.models.advertisement import AdCategoryEnum
from app.schemas.advertisement_schema import (
    AdvertisementCreate,
    AdvertisementSummary,
    AdvertisementDetail, AdvertisementSummaryList
)
from app.services.advertisement_service import AdvertisementService

router = APIRouter(prefix="/advertisements", tags=["advertisements"])

def get_advertisement_service(db: Session = Depends(get_db)) -> AdvertisementService:
    return AdvertisementService(db)

@router.post("/", response_model=AdvertisementDetail, status_code=status.HTTP_201_CREATED)
def create_advertisement(
    data: AdvertisementCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AdvertisementService = Depends(get_advertisement_service)
):
    return service.create_advertisement(data, auth.shelter_id)

@router.get("/me", response_model=AdvertisementSummaryList)
def get_my_advertisements(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AdvertisementService = Depends(get_advertisement_service)
):
    return {"advertisements":service.get_my_advertisements(auth.shelter_id)}

@router.get("/", response_model=AdvertisementSummaryList)
def get_advertisements(
    province_name: Optional[str] = Query(None, description="Filter by province name"),
    category: Optional[AdCategoryEnum] = Query(None, description="Filter by Ad Category"),
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AdvertisementService = Depends(get_advertisement_service)
):
    return {"advertisements":service.get_advertisements(province_name=province_name, category=category, shelter_id=auth.shelter_id)}

@router.get("/{ad_id}", response_model=AdvertisementDetail)
def get_advertisement_detail(
    ad_id: int,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: AdvertisementService = Depends(get_advertisement_service)
):
    return service.get_advertisement_by_id(ad_id)

@router.patch("/{ad_id}/deactivate", response_model=AdvertisementDetail)
def deactivate_advertisement(
    ad_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AdvertisementService = Depends(get_advertisement_service)
):
    return service.deactivate_advertisement(ad_id, auth.shelter_id)

@router.post("/{ad_id}/image", response_model=AdvertisementDetail)
def upload_advertisement_image(
    ad_id: int,
    file: UploadFile = File(...),
    auth: AuthenticatedUser = Depends(require_manager),
    service: AdvertisementService = Depends(get_advertisement_service)
):
    return service.upload_image(ad_id, file, auth.shelter_id)

@router.delete("/{ad_id}/image", response_model=AdvertisementDetail)
def delete_advertisement_image(
    ad_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: AdvertisementService = Depends(get_advertisement_service)
):
    return service.delete_image(ad_id, auth.shelter_id)