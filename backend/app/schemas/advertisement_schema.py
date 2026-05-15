from typing import Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict

from app.models.advertisement import AdCategoryEnum

class AdvertisementCreate(BaseModel):
    title: str
    description: str
    category: AdCategoryEnum
    province_name: str
    image_url: Optional[str] = None

class AdvertisementSummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    category: AdCategoryEnum
    province_name: str
    image_url: Optional[str] = None
    is_active: bool = True

class AdvertisementSummaryList(BaseModel):
    advertisements: list[AdvertisementSummary]

class AdvertisementDetail(AdvertisementSummary):
    description: str
    published_on: datetime
    is_active: bool
    shelter_id: int

    #populated through properties
    shelter_name: str
    shelter_email: str