from typing import Optional

from pydantic import BaseModel, ConfigDict


from app.schemas.refuge_schema import RefugeResponse


from app.schemas.province_schema import ProvinceResponse


class ShelterCreate(BaseModel):
    name: str
    province_id: str
    refuge_name: str
    shelter_email: str | None = None


class ShelterUpdate(BaseModel):
    name: Optional[str] = None
    province_id: Optional[str] = None


class ShelterResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    province: ProvinceResponse
    volunteer_code: str
    manager_code: str
    refuges: list[RefugeResponse]

class ShelterBasicInfoResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    province: ProvinceResponse
    refuges: list[RefugeResponse]

class ShelterWithTokenResponse(BaseModel):
    shelter: ShelterResponse
    access_token: str
    token_type: str = "bearer"