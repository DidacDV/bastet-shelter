from datetime import date
from typing import Optional, List

from pydantic import BaseModel, ConfigDict

from app.models.animal import AnimalTypeEnum
from app.schemas.trait_schema import TraitResponse


class AnimalCreate(BaseModel):
    name: str
    birth_date: date
    arrival_date: date | None = None
    description: str
    breed: str
    animal_type: AnimalTypeEnum
    in_adoption: bool = False
    refuge_id: int
    trait_ids: list[int] = []

class AnimalResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    birth_date: date
    arrival_date: date | None
    description: str
    breed: str
    animal_type: AnimalTypeEnum
    in_adoption: bool
    refuge_id: int
    image_url: str | None
    traits: list[TraitResponse] = []
    refuge_name: str | None = None

class AnimalShortInfo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    age: int
    in_adoption: bool
    pending_shift_tasks: int
    refuge_name: str

class AnimalSummaryInfoList(BaseModel):
    animals: list[AnimalShortInfo]

class AnimalUpdate(BaseModel):
    name: Optional[str] = None
    birth_date: Optional[date] = None
    arrival_date: Optional[date] = None
    description: Optional[str] = None
    breed: Optional[str] = None
    animal_type: Optional[str] = None
    in_adoption: Optional[bool] = None
    refuge_id: Optional[int] = None
    trait_ids: Optional[List[int]] = None