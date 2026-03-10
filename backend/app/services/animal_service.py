from sqlalchemy.orm import Session
from app.repositories.animal_repo import AnimalRepository
from app.models.animal import Animal

class AnimalService:
    def __init__(self, repository: AnimalRepository, db: Session):
        self.repository = repository
        self.db = db

    def get_animal(self, animal_id: int) -> Animal:
        animal = self.repository.get_by_id(self.db, animal_id)
        if not animal:
            raise ValueError(f"Animal {animal_id} not found")
        return animal