from typing import Optional

from pydantic import BaseModel, ConfigDict


class AdoptionFormSubmit(BaseModel):
    housing_type: Optional[str] = None
    has_garden: Optional[bool] = None
    has_other_pets: Optional[bool] = None
    other_pets_description: Optional[str] = None
    has_children: Optional[bool] = None
    children_ages: Optional[str] = None
    previous_pet_experience: Optional[bool] = None
    hours_alone_per_day: Optional[int] = None
    reason_for_adoption: Optional[str] = None


class AdoptionFormResponse(AdoptionFormSubmit):
    model_config = ConfigDict(from_attributes=True)

    id: int
    accepted: bool
