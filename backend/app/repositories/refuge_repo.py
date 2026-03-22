from sqlalchemy.orm import Session
from app.models.refuge import Refuge
from app.repositories.generic_repo import BaseRepository

class RefugeRepository(BaseRepository[Refuge]):
    def __init__(self):
        super().__init__(Refuge)

    def get_by_shelter(self, db: Session, shelter_id: int) -> list[Refuge]:
        return db.query(Refuge).filter(Refuge.shelter_id == shelter_id).all()
