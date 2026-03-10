from sqlalchemy.orm import Session
from app.models.animal import Animal
from app.repositories.generic_repo import BaseRepository

class AnimalRepository(BaseRepository[Animal]):
    def __init__(self):
        super().__init__(Animal)