from datetime import date

from app.models.animal.animal import Animal, AnimalTypeEnum
from app.models.refuge import Refuge
from app.models.trait import Trait
from app.repositories.trait_repo import TraitRepository
from tests.repositories.utils import _create_shelter


class TestTraitRepository:
    repo = TraitRepository(None)

    def test_is_used_by_animal(self, db):
        shelter = _create_shelter(db)
        refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
        trait = Trait(name="Friendly", shelter_id=shelter.id)
        unused_trait = Trait(name="Shy", shelter_id=shelter.id)
        db.add_all([refuge, trait, unused_trait])
        db.commit()
        db.refresh(refuge)
        db.refresh(trait)
        db.refresh(unused_trait)

        animal = Animal(
            name="Milo",
            link_name="milo",
            birth_date=date(2026, 1, 1),
            description="Desc",
            breed="Mixed",
            animal_type=AnimalTypeEnum.CAT,
            refuge_id=refuge.id,
        )
        animal.traits.append(trait)
        db.add(animal)
        db.commit()

        assert self.repo.is_used_by_animal(db, trait.id) is True
        assert self.repo.is_used_by_animal(db, unused_trait.id) is False
