from sqlalchemy.orm import Session
from app.models.refuge import Refuge
from app.repositories.refuge_repo import RefugeRepository
from app.schemas.refuge_schema import RefugeCreate, RefugeResponse

class RefugeService:
    def __init__(self, db: Session):
        self.db = db
        self.refuge_repo = RefugeRepository(db)

    def create_refuge(self, data: RefugeCreate, shelter_id: int) -> RefugeResponse:
        """Creates refuge linked to shelter"""
        new_refuge = Refuge(**data.model_dump(), shelter_id=shelter_id)
        created_refuge = self.refuge_repo.create(self.db, new_refuge)
        return RefugeResponse.model_validate(created_refuge)

    def get_refuges(self, shelter_id: int) -> list[RefugeResponse]:
        """All refuges for a shelter"""
        refuges = self.refuge_repo.get_by_shelter(self.db, shelter_id)
        return [RefugeResponse.model_validate(r) for r in refuges]
