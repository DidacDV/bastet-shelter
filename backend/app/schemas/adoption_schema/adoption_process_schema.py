from typing import Annotated, Optional, Union
from pydantic import BaseModel, ConfigDict, Field
from datetime import date

from app.models.adoption.adoption_process import AdoptionProcessStatusEnum
from app.schemas.adoption_schema.adoption_step_schema import (
    AdoptionStepResponse,
    AdoptionStepAdoptantSummary,
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

class AdoptionProcessResponseList(BaseModel):
    processes: list[AdoptionProcessResponse] = []

class AdoptionProcessDetailResponse(AdoptionProcessResponse):
    steps: list[AnyStepDetailResponse] = []

class AdoptionProcessAdoptantResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    animal_id: int
    animal_name: str
    animal_image_url: str | None = None
    start_date: date
    end_date: date | None = None
    status: AdoptionProcessStatusEnum
    rejection_reason: str | None = None
    current_step: Optional[AnyStepDetailResponse] = None
    steps: list[AdoptionStepAdoptantSummary] = []

class RejectionRequest(BaseModel):
    reason: str