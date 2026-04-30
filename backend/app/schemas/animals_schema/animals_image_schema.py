from pydantic import BaseModel, ConfigDict


class AnimalImageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    url: str
    cloudinary_public_id: str
    order: int