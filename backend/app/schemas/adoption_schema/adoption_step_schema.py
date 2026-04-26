from typing import Literal, Optional
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


class AdoptionStepBaseResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    status: StepStatusEnum
    order: int
    finish_date: Optional[date] = None
    notes: Optional[str] = None
    rejection_reason: Optional[str] = None
    is_current: bool = False


class AdoptionFormResponse(AdoptionStepBaseResponse):
    type: Literal[StepTypeEnum.FORM] = StepTypeEnum.FORM
    accepted: bool

class InterviewResponse(AdoptionStepBaseResponse):
    type: Literal[StepTypeEnum.INTERVIEW] = StepTypeEnum.INTERVIEW
    scheduled_at: Optional[datetime] = None

class ShelterVisitResponse(AdoptionStepBaseResponse):
    type: Literal[StepTypeEnum.SHELTER_VISIT] = StepTypeEnum.SHELTER_VISIT
    scheduled_at: Optional[datetime] = None

class ContractResponse(AdoptionStepBaseResponse):
    type: Literal[StepTypeEnum.CONTRACT] = StepTypeEnum.CONTRACT
    signed_by_adoptant: bool
    signed_by_shelter: bool
    contract_url: Optional[str] = None

class AnimalPickupResponse(AdoptionStepBaseResponse):
    type: Literal[StepTypeEnum.ANIMAL_PICKUP] = StepTypeEnum.ANIMAL_PICKUP
    scheduled_at: Optional[datetime] = None
    actual_pickup_at: Optional[datetime] = None