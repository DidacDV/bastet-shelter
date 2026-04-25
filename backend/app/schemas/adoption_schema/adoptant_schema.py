from pydantic import BaseModel, ConfigDict

class AdoptantResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: str
    name: str