from pydantic import BaseModel, ConfigDict


class AnimalBase(BaseModel):
    name: str

class AnimalCreate(AnimalBase):
    pass

class AnimalResponse(AnimalBase):
    model_config = ConfigDict(from_attributes=True)

    name: str