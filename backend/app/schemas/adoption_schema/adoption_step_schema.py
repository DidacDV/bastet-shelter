from typing import Optional
from pydantic import BaseModel, ConfigDict
from datetime import date, datetime

from app.models.adoption.adoption_steps.adoption_step import StepTypeEnum, StepStatusEnum


class AdvanceStepRequest(BaseModel):
    notes: Optional[str] = None

class AdoptionStepResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    type: StepTypeEnum
    status: StepStatusEnum
    order: int
    finish_date: Optional[date] = None
    notes: Optional[str] = None
    rejection_reason: Optional[str] = None


class AdoptionStepDetailResponse(AdoptionStepResponse):
    """includes subtype specific fields"""
    scheduled_at: Optional[datetime] = None         #interview & shelter_visit & animal_pickup
    actual_pickup_at: Optional[datetime] = None     #animal_pickup only
    accepted: Optional[bool] = None                 #form only
    signed_by_adoptant: Optional[bool] = None       #contract only
    signed_by_shelter: Optional[bool] = None        #contract only
    contract_url: Optional[str] = None              #contract only
    is_current: bool = False #general