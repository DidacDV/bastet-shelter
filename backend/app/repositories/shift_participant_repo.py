from sqlalchemy.orm import Session
from app.models.shift.shift_participant import ShiftParticipant
from app.repositories.generic_repo import BaseRepository

class ShiftParticipantRepository(BaseRepository[ShiftParticipant]):
    def __init__(self, db: Session):
        super().__init__(ShiftParticipant)
        self.db = db

    def get_by_shift(self, db: Session, shift_id: int) -> list[ShiftParticipant]:
        return db.query(ShiftParticipant).filter(ShiftParticipant.shift_id == shift_id).all()

    def get_by_volunteer(self, db: Session, volunteer_id: int) -> list[ShiftParticipant]:
        return db.query(ShiftParticipant).filter(ShiftParticipant.member_id == volunteer_id).all()

    def get_by_shift_and_member(self, db: Session, shift_id: int, member_id: int):
        return db.query(ShiftParticipant).filter(
            ShiftParticipant.shift_id == shift_id,
            ShiftParticipant.member_id == member_id
        ).first()