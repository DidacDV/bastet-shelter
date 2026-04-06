from sqlalchemy.orm import Session

from app.models.trait import Trait
from app.repositories.trait_repo import TraitRepository
from app.schemas.trait_schema import TraitCreate, TraitResponse


class TraitService:
    def __init__(self, db: Session):
        self.db = db
        self.trait_repo = TraitRepository(db)

    def add_trait(self, data: TraitCreate, shelter_id: int) -> TraitResponse:
        new_trait = Trait(name=data.name, shelter_id=shelter_id)
        created = self.trait_repo.create(self.db, new_trait)
        return TraitResponse.model_validate(created)

    def edit_trait(self, trait_id: int, data: TraitCreate, shelter_id: int) -> TraitResponse:
        trait = self.trait_repo.get_by_id(self.db, trait_id)
        if not trait:
            raise ValueError("Trait not found")
        if trait.shelter_id != shelter_id:
            raise ValueError("Trait does not belong to this shelter")
        updated = self.trait_repo.update(self.db, trait_id, {"name": data.name})
        return TraitResponse.model_validate(updated)

    def delete_trait(self, trait_id: int, shelter_id: int) -> None:
        trait = self.trait_repo.get_by_id(self.db, trait_id)
        if not trait:
            raise ValueError("Trait not found")
        if trait.shelter_id != shelter_id:
            raise ValueError("Trait does not belong to this shelter")
        self.trait_repo.delete(self.db, trait_id)
