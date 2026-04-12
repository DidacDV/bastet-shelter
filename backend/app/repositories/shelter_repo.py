from sqlalchemy.orm import Session

from app.models.shelter import Shelter
from app.repositories.generic_repo import BaseRepository


# noinspection PyMethodMayBeStatic
class ShelterRepository(BaseRepository[Shelter]):
    def __init__(self, db: Session = None):
        super().__init__(Shelter)
        self.db = db

    def get_by_manager_code(self, db: Session, code: str) -> Shelter | None:
        return db.query(Shelter).filter(Shelter.manager_code.ilike(code)).first()

    def get_by_volunteer_code(self, db: Session, code: str) -> Shelter | None:
        return db.query(Shelter).filter(Shelter.volunteer_code.ilike(code)).first()

    def update_volunteer_code(self, db: Session, shelter_id: int, code: str) -> None:
        shelter = db.query(Shelter).filter(Shelter.id == shelter_id).first()
        shelter.volunteer_code = code
        db.commit()

    def update_manager_code(self, db: Session, shelter_id: int, code: str) -> None:
        shelter = db.query(Shelter).filter(Shelter.id == shelter_id).first()
        shelter.manager_code = code
        db.commit()

shelter_repo = ShelterRepository()