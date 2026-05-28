from datetime import date

from app.models.adoption.adoptant import Adoptant
from app.models.adoption.adoption_process import AdoptionProcess, AdoptionProcessStatusEnum
from app.models.animal.animal import Animal, AnimalTypeEnum
from app.models.refuge import Refuge
from app.repositories.animal_repo import AnimalRepository
from tests.repositories.utils import _create_shelter


class TestAnimalRepository:
    repo = AnimalRepository(None)

    def test_get_portal_short_info_excludes_animals_with_active_adoption_process(self, db):
        shelter = _create_shelter(db)
        refuge = Refuge(name="Main Refuge", province_id="08", shelter_id=shelter.id)
        available_animal = Animal(
            name="Milo",
            link_name="milo",
            birth_date=date(2024, 1, 1),
            description="Desc",
            breed="Mixed",
            animal_type=AnimalTypeEnum.CAT,
            in_adoption=True,
            refuge_id=0,
        )
        reserved_animal = Animal(
            name="Luna",
            link_name="luna",
            birth_date=date(2024, 2, 1),
            description="Desc",
            breed="Mixed",
            animal_type=AnimalTypeEnum.DOG,
            in_adoption=True,
            refuge_id=0,
        )
        db.add(refuge)
        db.flush()
        available_animal.refuge_id = refuge.id
        reserved_animal.refuge_id = refuge.id
        db.add_all([available_animal, reserved_animal])
        db.flush()

        adoptant = Adoptant(email="adoptant@example.com", name="Jane Doe")
        db.add(adoptant)
        db.flush()
        db.add(
            AdoptionProcess(
                animal_id=reserved_animal.id,
                adoptant_id=adoptant.id,
                start_date=date.today(),
                status=AdoptionProcessStatusEnum.ACTIVE,
            )
        )
        db.commit()

        results = self.repo.get_portal_short_info(db, "08")

        assert [row.id for row in results] == [available_animal.id]
