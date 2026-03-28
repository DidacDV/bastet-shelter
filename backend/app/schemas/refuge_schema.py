from pydantic import BaseModel, ConfigDict


from app.schemas.province_schema import ProvinceResponse


class RefugeCreate(BaseModel):
    name: str
    province_id: str


class RefugeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    province: ProvinceResponse
    shelter_id: int