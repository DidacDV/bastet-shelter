from sqlalchemy.orm import Session
from app.models.animal import Animal
from app.repositories.animal_repo import AnimalRepository
from app.repositories.refuge_repo import RefugeRepository
from app.schemas.animals_schema import AnimalCreate, AnimalResponse

class AnimalService:
    def __init__(self, db: Session):
        self.db = db
        self.animal_repo = AnimalRepository(db)
        self.refuge_repo = RefugeRepository(db)

    def register_animal(self, data: AnimalCreate, shelter_id: int) -> AnimalResponse:
        """Validates refuge belongs to shelter, then creates"""
        refuge = self.refuge_repo.get_by_id(self.db, data.refuge_id)
        if not refuge or refuge.shelter_id != shelter_id:
            raise ValueError("Refuge does not belong to this shelter")
        
        new_animal = Animal(**data.model_dump())
        created_animal = self.animal_repo.create(self.db, new_animal)
        return AnimalResponse.model_validate(created_animal)

    def get_animals(self, refuge_id: int) -> list[AnimalResponse]:
        """List animals in a refuge"""
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge:
            raise ValueError("Refuge not found")
        animals = self.animal_repo.get_by_refuge(self.db, refuge_id)
        return [AnimalResponse.model_validate(a) for a in animals]

    def set_in_adoption(self, animal_id: int) -> AnimalResponse:
        """Toggle adoption status"""
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise ValueError("Animal not found")
        
        updated_animal = self.animal_repo.update_adoption_status(self.db, animal_id, not animal.in_adoption)
        return AnimalResponse.model_validate(updated_animal)

    def get_animal_by_id(self, animal_id: int) -> AnimalResponse:
        """Get animal details by ID"""
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise ValueError("Animal not found")
        return AnimalResponse.model_validate(animal)
