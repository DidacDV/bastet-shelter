from datetime import date
from typing import Optional

from pydantic import BaseModel, ConfigDict

from app.models.task.task import TaskStatusEnum
from app.schemas.animals_schema.animals_schema import AnimalShortInfo
from app.schemas.shift_schema.shift_participant_schema import ShiftParticipantResponse
from app.schemas.task_schema.task_schema import TaskResponse


class ShiftTaskCreate(BaseModel):
    shift_id: int
    task_id: int
    assigned_date: date
    participant_id: Optional[int] = None
    animal_id: Optional[int] = None


class ShiftTaskResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    status: TaskStatusEnum
    assigned_date: date
    shift_id: int
    task_id: int
    task: TaskResponse
    participant: Optional[ShiftParticipantResponse] = None
    animal: Optional[AnimalShortInfo] = None