from sqlalchemy.orm import Session
from app.models.adoption.adoptant import Adoptant
from app.models.adoption.adoption_process import AdoptionProcess
from app.repositories.generic_repo import BaseRepository

class AdoptantRepository(BaseRepository[Adoptant]):
    def __init__(self, db: Session):
        super().__init__(Adoptant)
        self.db = db

    def get_by_email(self, db: Session, email: str) -> type[Adoptant] | None:
        return db.query(Adoptant).filter(Adoptant.email == email).first()

    def get_or_create(self, db: Session, email: str, name: str) -> type[Adoptant] | Adoptant:
        adoptant = self.get_by_email(db, email)
        if not adoptant:
            adoptant = Adoptant(email=email, name=name)
            db.add(adoptant)
            db.commit()
            db.refresh(adoptant)
        return adoptant

    def has_process_in_shelter(self, db: Session, adoptant_id: int, shelter_id: int) -> bool:
        from app.models.animal.animal import Animal
        from app.models.refuge import Refuge
        return (
                db.query(AdoptionProcess)
                .join(Animal, AdoptionProcess.animal_id == Animal.id)
                .join(Refuge, Animal.refuge_id == Refuge.id)
                .filter(
                    AdoptionProcess.adoptant_id == adoptant_id,
                    Refuge.shelter_id == shelter_id
                )
                .first() is not None
        )