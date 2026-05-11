from datetime import date, timedelta
from sqlalchemy.orm import Session, selectinload
from app.models.shift.shift import Shift
from app.repositories.generic_repo import BaseRepository

class ShiftRepository(BaseRepository[Shift]):
    def __init__(self, db: Session):
        super().__init__(Shift)
        self.db = db

    def get_by_refuge(self, db: Session, refuge_id: int) -> list[type[Shift]]:
        return db.query(Shift).filter(Shift.refuge_id == refuge_id).options(selectinload(Shift.participants)).all()

    def get_by_date(self, db: Session, day: date) -> list[type[Shift]]:
        return db.query(Shift).filter(Shift.day == day).options(selectinload(Shift.participants)).all()

    def get_by_refuge_and_week(self, db: Session, refuge_id: int, week_start: date) -> list[type[Shift]]:
        """Returns all shifts for a refuge within a 7-day window starting from week_start"""
        week_end = week_start + timedelta(days=6)
        return (
            db.query(Shift)
            .options(selectinload(Shift.participants))
            .filter(
                Shift.refuge_id == refuge_id,
                Shift.day >= week_start,
                Shift.day <= week_end,
            )
            .all()
        )
    def delete_shift(self, db: Session, shift: Shift) -> None:
        db.delete(shift)
        db.commit()

    def delete_by_refuge_and_day(self, db: Session, refuge_id: int, day: date) -> int:
        shifts = (
            db.query(Shift)
            .filter(Shift.refuge_id == refuge_id, Shift.day == day)
            .all()
        )
        for shift in shifts:
            db.delete(shift)
        db.commit()
        return len(shifts)

    def delete_by_refuge_and_week(self, db: Session, refuge_id: int, week_start: date) -> int:
        week_end = week_start + timedelta(days=6)
        shifts = (
            db.query(Shift)
            .filter(
                Shift.refuge_id == refuge_id,
                Shift.day >= week_start,
                Shift.day <= week_end,
            )
            .all()
        )
        for shift in shifts:
            db.delete(shift)
        db.commit()
        return len(shifts)