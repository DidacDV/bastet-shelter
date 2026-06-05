from typing import List, Optional
from sqlalchemy.orm import Session

from app.models.advertisement import Advertisement, AdCategoryEnum
from app.repositories.generic_repo import BaseRepository


class AdvertisementRepository(BaseRepository[Advertisement]):
    def __init__(self, db: Session):
        super().__init__(Advertisement)
        self.db = db

    def get_by_shelter(self, db: Session, shelter_id: int) -> list[type[Advertisement]]:
        return (
            db.query(Advertisement)
            .filter(Advertisement.shelter_id == shelter_id)
            .order_by(Advertisement.published_on.desc())
            .all()
        )

    def get_active_advertisements(
        self, db: Session, province_id: Optional[str] = None, category: Optional[AdCategoryEnum] = None,
        skip: int = 0, limit: Optional[int] = None
    ) -> tuple[list, int]:
        query = db.query(Advertisement).filter(Advertisement.is_active == True)

        if province_id:
            query = query.filter(Advertisement.province_id == province_id)
        if category:
            query = query.filter(Advertisement.category == category)

        query = query.order_by(Advertisement.published_on.desc())

        total = query.count()

        if skip:
            query = query.offset(skip)
        if limit is not None:
            query = query.limit(limit)

        return query.all(), total