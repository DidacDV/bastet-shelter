from datetime import date

from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.models.medical.medical_treatment import AnimalTreatment
from app.models.medical.medicine import Medicine
from app.repositories.generic_repo import BaseRepository


class MedicineRepository(BaseRepository[Medicine]):
    def __init__(self, db: Session):
        super().__init__(Medicine)
        self.db = db

    def get_by_shelter(self, db: Session, shelter_id: int) -> list[Medicine]:
        return db.query(Medicine).filter(Medicine.shelter_id == shelter_id).all()

    def get_by_name_and_shelter(self, db: Session, name: str, shelter_id: int) -> Medicine | None:
        return db.query(Medicine).filter(Medicine.name == name, Medicine.shelter_id == shelter_id).first()

    def is_used_in_active_treatment(self, db: Session, medicine_id: int) -> bool:
        today = date.today()
        return (
            db.query(AnimalTreatment.id)
            .filter(
                AnimalTreatment.medicine_id == medicine_id,
                or_(AnimalTreatment.end_date.is_(None), AnimalTreatment.end_date >= today),
            )
            .first()
            is not None
        )
