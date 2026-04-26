from typing import Annotated, Optional, Union
from pydantic import BaseModel, ConfigDict, Field
from datetime import date

from app.models.adoption.adoption_process import AdoptionProcessStatusEnum
from app.schemas.adoption_schema.adoption_step_schema import (
    AdoptionStepResponse,
    AdoptionFormResponse,
    InterviewResponse,
    ShelterVisitResponse,
    ContractResponse,
    AnimalPickupResponse,
)

AnyStepDetailResponse = Annotated[
    Union[AdoptionFormResponse, InterviewResponse, ShelterVisitResponse, ContractResponse, AnimalPickupResponse],
    Field(discriminator="type")
]

class AdoptionProcessResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    animal_id: int
    animal_name: str
    animal_image_url: str | None = None
    adoptant_id: int
    adoptant_name: str
    start_date: date
    end_date: date | None = None
    status: AdoptionProcessStatusEnum
    steps: list[AdoptionStepResponse] = []
    rejection_reason: str | None = None

class AdoptionProcessDetailResponse(AdoptionProcessResponse):
    steps: list[AnyStepDetailResponse] = []

class RejectionRequest(BaseModel):
    reason: str