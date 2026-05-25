from datetime import datetime, date
from typing import List
from pydantic import BaseModel, ConfigDict
from app.schemas.task_schema.shift_task_schema import ShiftTaskResponse

class ShiftCreate(BaseModel):
    start_time: datetime
    end_time: datetime
    day: date
    max_participants: int | None = None
    task_ids: list[int] = []

class ShiftResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    start_time: datetime
    end_time: datetime
    day: date
    refuge_id: int
    max_participants: int | None = None
    current_participants: int = 0

class ShiftDetailResponse(ShiftResponse):
    shift_tasks: List[ShiftTaskResponse] = []
    is_joined: bool = False
    my_participant_id: int | None = None

class ListShiftResponse(BaseModel):
    shifts: list[ShiftResponse]

class ShiftUpdate(BaseModel):
    start_time: datetime | None = None
    end_time: datetime | None = None
    refuge_id: int | None = None
    max_participants: int | None = None

class MyShiftTasksGroup(BaseModel):
    shift: ShiftResponse
    tasks: List[ShiftTaskResponse]

class ListMyShiftTaskGroupResponse(BaseModel):
    my_shift_tasks: List[MyShiftTasksGroup]