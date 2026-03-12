from datetime import date
from pydantic import BaseModel

from app.models.shelter_member import RoleEnum


class ShelterMemberCreate(BaseModel):
    user_id: int
    shelter_id: int
    role: RoleEnum

class ShelterMemberResponse(BaseModel):
    id: int
    user_id: int
    shelter_id: int
    role: RoleEnum
    join_date: date

class ShelterMemberInfo(BaseModel):
    name: str
    shelter_code: str
    role: RoleEnum
    join_date: date

    class Config:
        from_attributes = True
