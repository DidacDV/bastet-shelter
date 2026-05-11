from datetime import datetime, date

from pydantic import BaseModel, ConfigDict

class ShiftCreate(BaseModel):
    start_time: datetime
    end_time: datetime
    day: date
    max_participants: int | None = None

class ShiftResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    start_time: datetime
    end_time: datetime
    day: date
    refuge_id: int
    max_participants: int | None = None
    current_participants: int = 0

class ListShiftResponse(BaseModel):
    shifts: list[ShiftResponse]