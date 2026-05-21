from sqlalchemy.orm import Session

from app.models.animal.animal import animal_trait_association
from app.models.trait import Trait
from app.repositories.generic_repo import BaseRepository


class TraitRepository(BaseRepository[Trait]):
    def __init__(self, db: Session):
        super().__init__(Trait)
        self.db = db

    def get_by_shelter(self, db: Session, shelter_id: int) -> list[type[Trait]]:
        return db.query(Trait).filter(Trait.shelter_id == shelter_id).all()

    def get_by_ids_and_shelter(self, db: Session, trait_ids: list[int], shelter_id: int) -> list[type[Trait]]:
        """Fetches only the traits that exist in the list AND belong to the shelter"""
        return (
            db.query(Trait)
            .filter(
                Trait.id.in_(trait_ids),
                Trait.shelter_id == shelter_id
            )
            .all()
        )

    def create_default_traits(self, db: Session, shelter_id: int, trait_names: list[str]) -> list[Trait]:
        """Creates set of default traits for a specific shelter"""
        traits = [
            Trait(name=name, shelter_id=shelter_id)
            for name in trait_names
        ]
        db.add_all(traits)
        db.commit()
        return traits

    def is_used_by_animal(self, db: Session, trait_id: int) -> bool:
        return (
            db.query(animal_trait_association.c.animal_id)
            .filter(animal_trait_association.c.trait_id == trait_id)
            .first()
            is not None
        )
