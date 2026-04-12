from sqlalchemy.orm import Session

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
