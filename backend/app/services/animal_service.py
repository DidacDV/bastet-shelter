from datetime import date

from sqlalchemy.orm import Session
from app.models.animal import Animal
from app.repositories.animal_repo import AnimalRepository
from app.repositories.refuge_repo import RefugeRepository
from app.repositories.trait_repo import TraitRepository
from app.schemas.animals_schema import AnimalCreate, AnimalResponse, AnimalShortInfo, AnimalUpdate


class AnimalService:
    def __init__(self, db: Session):
        self.db = db
        self.animal_repo = AnimalRepository(db)
        self.refuge_repo = RefugeRepository(db)
        self.trait_repo = TraitRepository(db)

    def _to_response(self, animal: Animal) -> AnimalResponse:
        return AnimalResponse(
            id=animal.id,
            name=animal.name,
            birth_date=animal.birth_date,
            arrival_date=animal.arrival_date,
            description=animal.description,
            breed=animal.breed,
            animal_type=animal.animal_type,
            in_adoption=animal.in_adoption,
            refuge_id=animal.refuge_id,
            refuge_name=animal.refuge.name,
            traits=animal.traits,
            image_url=None,
        )

    def register_animal(self, data: AnimalCreate, shelter_id: int) -> AnimalResponse:
        refuge = self.refuge_repo.get_by_id(self.db, data.refuge_id)
        if not refuge or refuge.shelter_id != shelter_id:
            raise ValueError("Refuge does not belong to this shelter")

        animal_data = data.model_dump()
        trait_ids = animal_data.pop("trait_ids", [])
        new_animal = Animal(**animal_data)

        if trait_ids:
            new_animal.traits = self.trait_repo.get_by_ids_and_shelter(
                self.db,
                trait_ids,
                shelter_id
            )

        created_animal = self.animal_repo.create(self.db, new_animal)
        return self._to_response(created_animal)

    def get_animals(self, refuge_id: int) -> list[AnimalResponse]:
        """List animals in a refuge"""
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge:
            raise ValueError("Refuge not found")
        animals = self.animal_repo.get_by_refuge(self.db, refuge_id)
        return [self._to_response(a) for a in animals]

    def set_in_adoption(self, animal_id: int) -> AnimalResponse:
        """Toggle adoption status"""
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise ValueError("Animal not found")
        
        updated_animal = self.animal_repo.update_adoption_status(self.db, animal_id, not animal.in_adoption)
        return self._to_response(updated_animal)

    def get_animal_by_id(self, animal_id: int) -> AnimalResponse:
        """Get animal details by ID"""
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise ValueError("Animal not found")
        return self._to_response(animal)

    def get_all_animals_short_info(self, shelter_id: int) -> list[AnimalShortInfo]:
        """Gets short info to display in mobile app, calculating the age of each animal"""
        results = self.animal_repo.get_all_short_info(self.db, shelter_id)

        short_info_list = []
        today = date.today()

        for row in results:
            age = today.year - row.birth_date.year - (
                    (today.month, today.day) < (row.birth_date.month, row.birth_date.day)
            )

            short_info_list.append(
                AnimalShortInfo(
                    id=row.id,
                    name=row.name,
                    age=age,
                    in_adoption=row.in_adoption,
                    pending_shift_tasks=row.pending_shift_tasks,
                    refuge_name=row.refuge_name
                )
            )

        return short_info_list

    def update_animal(self, animal_id: int, data: AnimalUpdate, shelter_id: int) -> AnimalResponse:
        """Update specific fields of an animal."""

        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise ValueError("Animal not found")

        refuge = self.refuge_repo.get_by_id(self.db, animal.refuge_id)
        if not refuge or refuge.shelter_id != shelter_id:
            raise ValueError("Not authorized to edit this animal")

        update_data = data.model_dump(exclude_unset=True)

        if "trait_ids" in update_data:
            trait_ids = update_data.pop("trait_ids")
            animal.traits = self.trait_repo.get_by_ids_and_shelter(
                self.db,
                trait_ids,
                shelter_id
            )

        if update_data:
            updated_animal = self.animal_repo.update(self.db, animal_id, update_data)
        else:
            self.db.commit()
            self.db.refresh(animal)
            updated_animal = animal

        return self._to_response(updated_animal)