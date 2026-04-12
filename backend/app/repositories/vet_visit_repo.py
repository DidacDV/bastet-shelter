from sqlalchemy.orm import Session

from app.models.medical.vet_visit import VetVisit
from app.repositories.generic_repo import BaseRepository


class VetVisitRepository(BaseRepository[VetVisit]):
    def __init__(self, db: Session):
        super().__init__(VetVisit)
        self.db = db

    def get_by_animal(self, db: Session, animal_id: int) -> list[VetVisit]:
        return db.query(VetVisit).filter(VetVisit.animal_id == animal_id).all()
