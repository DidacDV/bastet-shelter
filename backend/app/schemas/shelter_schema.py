from typing import Optional

from pydantic import BaseModel, ConfigDict


from app.schemas.refuge_schema import RefugeResponse


class ShelterCreate(BaseModel):
    name: str
    location: str
    refuge_name: str


class ShelterResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    name: str
    location: str
    volunteer_code: str
    manager_code: str
    refuges: list[RefugeResponse]

class ShelterBasicInfoResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    name: str
    location: str
    refuges: list[RefugeResponse]

class ShelterWithTokenResponse(BaseModel):
    shelter: ShelterResponse
    access_token: str
    token_type: str = "bearer"