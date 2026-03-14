from pydantic import BaseModel, ConfigDict


class ShelterCreate(BaseModel):
    name: str
    location: str


class ShelterResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    name: str
    location: str
    volunteer_code: str
    manager_code: str


class ShelterWithTokenResponse(BaseModel):
    shelter: ShelterResponse
    access_token: str
    token_type: str = "bearer"