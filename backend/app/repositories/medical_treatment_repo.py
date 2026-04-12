from sqlalchemy.orm import Session

from app.models.medical.medical_treatment import AnimalTreatment
from app.repositories.generic_repo import BaseRepository


class MedicalTreatmentRepository(BaseRepository[AnimalTreatment]):
    def __init__(self, db: Session):
        super().__init__(AnimalTreatment)
        self.db = db

    def get_by_animal(self, db: Session, animal_id: int) -> list[AnimalTreatment]:
        return db.query(AnimalTreatment).filter(AnimalTreatment.animal_id == animal_id).all()
