from typing import Optional

from pydantic import BaseModel, ConfigDict


class ShiftParticipantResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    shift_id: int
    volunteer_id: Optional[int]

    name: Optional[str] = None
    last_name_1: Optional[str] = None