from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError
from app.models.trait import Trait
from app.repositories.trait_repo import TraitRepository
from app.schemas.trait_schema import TraitCreate, TraitResponse


class TraitService:
    def __init__(self, db: Session):
        self.db = db
        self.trait_repo = TraitRepository(db)

    def get_traits(self, shelter_id: int) -> list[TraitResponse]:
        traits = self.trait_repo.get_by_shelter(self.db, shelter_id)
        return [TraitResponse.model_validate(t) for t in traits]

    def add_trait(self, data: TraitCreate, shelter_id: int) -> TraitResponse:
        new_trait = Trait(name=data.name, shelter_id=shelter_id)
        created = self.trait_repo.create(self.db, new_trait)
        return TraitResponse.model_validate(created)

    def edit_trait(self, trait_id: int, data: TraitCreate, shelter_id: int) -> TraitResponse:
        trait = self.trait_repo.get_by_id(self.db, trait_id)
        if not trait:
            raise NotFoundError("Trait not found")
        if trait.shelter_id != shelter_id:
            raise AuthorizationError("Trait does not belong to this shelter")

        updated = self.trait_repo.update(self.db, trait_id, {"name": data.name})
        return TraitResponse.model_validate(updated)

    def delete_trait(self, trait_id: int, shelter_id: int) -> None:
        trait = self.trait_repo.get_by_id(self.db, trait_id)
        if not trait:
            raise NotFoundError("Trait not found")
        if trait.shelter_id != shelter_id:
            raise AuthorizationError("Trait does not belong to this shelter")
        if self.trait_repo.is_used_by_animal(self.db, trait_id):
            raise BusinessLogicError("Trait is used by an animal and cannot be deleted")

        self.trait_repo.delete(self.db, trait_id)