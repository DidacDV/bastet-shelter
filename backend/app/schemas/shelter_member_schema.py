from datetime import date
from pydantic import BaseModel, ConfigDict

from app.models.shelter_member import RoleEnum


class ShelterMemberCreate(BaseModel):
    user_id: int
    shelter_id: int
    role: RoleEnum

class ShelterMemberResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    shelter_id: int
    role: RoleEnum
    join_date: date

class ShelterMemberInfo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    name: str
    role: RoleEnum
    join_date: date
