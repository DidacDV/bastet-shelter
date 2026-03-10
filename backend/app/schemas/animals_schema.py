from pydantic import BaseModel

class AnimalBase(BaseModel):
    name: str

class AnimalCreate(AnimalBase):
    pass

class AnimalResponse(AnimalBase):
    name: str

    class Config:
        from_attributes = True