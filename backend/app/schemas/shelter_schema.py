from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.schemas.refuge_schema import RefugeResponse


from app.schemas.province_schema import ProvinceResponse


class ShelterCreate(BaseModel):
    name: str
    province_id: str
    refuge_name: str
    shelter_email: EmailStr


class ShelterUpdate(BaseModel):
    name: Optional[str] = None
    province_id: Optional[str] = None
    email: Optional[EmailStr] = None


class ShelterResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    link_name: str
    shelter_email: str | None = Field(validation_alias="email", default=None)
    province: ProvinceResponse
    volunteer_code: str
    manager_code: str
    refuges: list[RefugeResponse]

class ExternalIntegrationResponse(BaseModel):
    portal_base_url: str
    shelter_link_name: str
    url_pattern: str
    button_html_template: str
    usage_hint: str
    duplicate_name_hint: str

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