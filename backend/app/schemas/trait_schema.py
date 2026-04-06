from pydantic import BaseModel, ConfigDict


class TraitCreate(BaseModel):
    name: str


class TraitResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    shelter_id: int