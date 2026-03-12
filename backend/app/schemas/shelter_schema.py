from pydantic import BaseModel

class ShelterCreate(BaseModel):
    name: str
    location: str

class ShelterResponse(BaseModel):
    name: str
    location: str
    code: str

    class Config:
        from_attributes = True