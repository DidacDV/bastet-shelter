from datetime import datetime, date

from pydantic import BaseModel, ConfigDict

class ShiftCreate(BaseModel):
    start_time: datetime
    end_time: datetime
    day: date


class ShiftResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    start_time: datetime
    end_time: datetime
    day: date
    refuge_id: int

class ListShiftResponse(BaseModel):
    shifts: list[ShiftResponse]