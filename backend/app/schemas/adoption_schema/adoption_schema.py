"""generic adoption schemas"""

from datetime import datetime
from pydantic import BaseModel, EmailStr

class AdoptantCreate(BaseModel):
    email: EmailStr
    name: str

class ScheduledDateUpdate(BaseModel):
    scheduled_at: datetime

class NotesUpdate(BaseModel):
    notes: str