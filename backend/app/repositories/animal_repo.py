from sqlalchemy.orm import Session
from app.models.animal import Animal
from app.models.refuge import Refuge
from app.repositories.generic_repo import BaseRepository

class AnimalRepository(BaseRepository[Animal]):
    def __init__(self, db: Session):
        super().__init__(Animal)
        self.db = db

    def get_by_refuge(self, db: Session, refuge_id: int) -> list[Animal]:
        return db.query(Animal).filter(Animal.refuge_id == refuge_id).all()

    def update_adoption_status(self, db: Session, animal_id: int, in_adoption: bool) -> Animal | None:
        animal = self.get_by_id(db, animal_id)
        if animal:
            animal.in_adoption = in_adoption
            db.commit()
            db.refresh(animal)
        return animal

    def count_by_shelter(self, db: Session, shelter_id: int) -> int:
        return (db.query(Animal).join(Refuge).filter(Refuge.shelter_id == shelter_id)
            .count())