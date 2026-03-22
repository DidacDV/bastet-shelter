from sqlalchemy.orm import Session
from app.models.shift.shift_participant import ShiftParticipant
from app.repositories.generic_repo import BaseRepository

class ShiftParticipantRepository(BaseRepository[ShiftParticipant]):
    def __init__(self):
        super().__init__(ShiftParticipant)

    def get_by_shift(self, db: Session, shift_id: int) -> list[ShiftParticipant]:
        return db.query(ShiftParticipant).filter(ShiftParticipant.shift_id == shift_id).all()

    def get_by_volunteer(self, db: Session, volunteer_id: int) -> list[ShiftParticipant]:
        return db.query(ShiftParticipant).filter(ShiftParticipant.volunteer_id == volunteer_id).all()
