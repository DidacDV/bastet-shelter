from sqlalchemy.orm import Session

from app.models.shelter import Shelter
from app.repositories.generic_repo import BaseRepository


# noinspection PyMethodMayBeStatic
class ShelterRepository(BaseRepository[Shelter]):
    def __init__(self):
        super().__init__(Shelter)

    def get_by_code(self, db: Session, code: str) -> Shelter | None:
        return db.query(Shelter).filter(Shelter.code == code).first()

shelter_repo = ShelterRepository()