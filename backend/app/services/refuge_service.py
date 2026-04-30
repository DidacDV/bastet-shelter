from sqlalchemy.orm import Session
from app.models.refuge import Refuge
from app.repositories.refuge_repo import RefugeRepository
from app.schemas.refuge_schema import RefugeCreate, RefugeResponse, RefugeUpdate
from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError

class RefugeService:
    def __init__(self, db: Session):
        self.db = db
        self.refuge_repo = RefugeRepository(db)

    def update_refuge(self, refuge_id: int, shelter_id: int, data: RefugeUpdate) -> RefugeResponse:
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge:
            raise NotFoundError("Refuge not found")
        if refuge.shelter_id != shelter_id:
            raise AuthorizationError("Refuge does not belong to this shelter")

        update_data = data.model_dump(exclude_unset=True)
        updated_refuge = self.refuge_repo.update(self.db, refuge_id, update_data)
        return RefugeResponse.model_validate(updated_refuge)

    def create_refuge(self, data: RefugeCreate, shelter_id: int) -> RefugeResponse:
        """Creates refuge linked to shelter"""
        new_refuge = Refuge(**data.model_dump(), shelter_id=shelter_id)
        created_refuge = self.refuge_repo.create(self.db, new_refuge)
        return RefugeResponse.model_validate(created_refuge)

    def get_refuges(self, shelter_id: int) -> list[RefugeResponse]:
        """All refuges for a shelter"""
        refuges = self.refuge_repo.get_by_shelter(self.db, shelter_id)
        return [RefugeResponse.model_validate(r) for r in refuges]

    def delete_refuge(self, refuge_id: int, shelter_id: int) -> None:
        """Deletes refuge if it has no animals or shifts and its not the last one"""
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge:
            raise NotFoundError("Refuge not found")
        if refuge.shelter_id != shelter_id:
            raise NotFoundError("Refuge not found")

        if refuge.animals:
            raise BusinessLogicError("Cannot delete refuge with animals. You have to move them out first.")

        if refuge.shifts:
            raise BusinessLogicError("Cannot delete refuge with shifts. You have to move them out first.")

        all_refuges = self.refuge_repo.get_by_shelter(self.db, shelter_id)
        if len(all_refuges) <= 1:
            raise BusinessLogicError("Cannot delete the last refuge of a shelter.")

        self.refuge_repo.delete(self.db, refuge_id)