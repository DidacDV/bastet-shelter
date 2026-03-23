from datetime import date
from sqlalchemy.orm import Session
from app.models.shift.shift import Shift
from app.repositories.generic_repo import BaseRepository

class ShiftRepository(BaseRepository[Shift]):
    def __init__(self, db: Session):
        super().__init__(Shift)
        self.db = db

    def get_by_refuge(self, db: Session, refuge_id: int) -> list[Shift]:
        return db.query(Shift).filter(Shift.refuge_id == refuge_id).all()

    def get_by_date(self, db: Session, day: date) -> list[Shift]:
        return db.query(Shift).filter(Shift.day == day).all()
