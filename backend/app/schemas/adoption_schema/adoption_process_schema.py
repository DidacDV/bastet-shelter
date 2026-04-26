from pydantic import BaseModel, ConfigDict
from datetime import date
from typing import Optional

from app.models.adoption.adoption_process import AdoptionProcessStatusEnum
from app.schemas.adoption_schema.adoption_step_schema import AdoptionStepResponse, AdoptionStepDetailResponse


class AdoptionProcessResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    animal_id: int
    adoptant_id: int
    start_date: date
    end_date: Optional[date] = None
    status: AdoptionProcessStatusEnum
    steps: list[AdoptionStepResponse] = []
    rejection_reason: Optional[str] = None

class AdoptionProcessDetailResponse(AdoptionProcessResponse):
    steps: list[AdoptionStepDetailResponse] = []

class RejectionRequest(BaseModel):
    reason: str
