from sqlalchemy.orm import Session
from app.models.adoption.adoptant import Adoptant
from app.repositories.generic_repo import BaseRepository

class AdoptantRepository(BaseRepository[Adoptant]):
    def __init__(self, db: Session):
        super().__init__(Adoptant)
        self.db = db

    def get_by_email(self, db: Session, email: str) -> type[Adoptant] | None:
        return db.query(Adoptant).filter(Adoptant.email == email).first()