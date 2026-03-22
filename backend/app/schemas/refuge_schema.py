from pydantic import BaseModel, ConfigDict


class RefugeCreate(BaseModel):
    name: str
    location: str


class RefugeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    location: str
    shelter_id: int