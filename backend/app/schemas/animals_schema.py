from datetime import date

from pydantic import BaseModel, ConfigDict

from app.models.animal import AnimalTypeEnum


class AnimalCreate(BaseModel):
    name: str
    birth_date: date
    description: str
    breed: str
    animal_type: AnimalTypeEnum
    in_adoption: bool = False
    refuge_id: int


class AnimalResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    birth_date: date
    description: str
    breed: str
    animal_type: AnimalTypeEnum
    in_adoption: bool
    refuge_id: int

class AnimalSummaryInfoList(BaseModel):
    animals: list[AnimalShortInfo]

class AnimalShortInfo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    age: int
    in_adoption: bool
    pending_shift_tasks: int
    refuge_name: str