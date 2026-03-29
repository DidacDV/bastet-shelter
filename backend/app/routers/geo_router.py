from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.geo_service import GeoService
from app.schemas.province_schema import ProvinceResponse, ProvinceListResponse

router = APIRouter(prefix="/geo", tags=["geo"])

@router.get("/provinces", response_model=ProvinceListResponse)
async def get_provinces(db: Session = Depends(get_db)):
    provinces = GeoService.get_provinces(db)
    #TODO: FIX WHATEVER THIS IS TO DO IT IN SERVICE
    formatted_provinces = [{"name": p[0], "id": p[1]} for p in provinces]

    return {"provinces": formatted_provinces}