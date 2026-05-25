from sqlalchemy.orm import Session
from app.models.province import Province
from app.repositories.generic_repo import BaseRepository

class GeoRepository(BaseRepository[Province]):
    def __init__(self, db: Session):
        super().__init__(Province)
        self.db = db

    def get_province_by_name(self, db: Session, name: str) -> type[Province] | None:
        return db.query(Province).filter(Province.name.ilike(name)).first()