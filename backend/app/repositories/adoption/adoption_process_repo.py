from sqlalchemy.orm import Session, joinedload

from app.models.adoption.adoption_process import AdoptionProcess, AdoptionProcessStatusEnum
from app.repositories.generic_repo import BaseRepository
from app.models.animal.animal import Animal
from app.models.refuge import Refuge

class AdoptionProcessRepository(BaseRepository[AdoptionProcess]):
    def __init__(self, db: Session):
        super().__init__(AdoptionProcess)
        self.db = db

    def get_by_id_with_steps(self, db: Session, process_id: int) -> type[AdoptionProcess] | None:
        return (
            db.query(AdoptionProcess)
            .options(joinedload(AdoptionProcess.steps))
            .filter(AdoptionProcess.id == process_id)
            .first()
        )

    def get_active_process_for_animal(self, db: Session, animal_id: int) -> type[AdoptionProcess] | None:
        return (
            db.query(AdoptionProcess)
            .filter(
                AdoptionProcess.animal_id == animal_id,
                AdoptionProcess.status == AdoptionProcessStatusEnum.ACTIVE
            )
            .first()
        )

    def get_processes_for_adoptant(self, db: Session, adoptant_id: int) -> list[type[AdoptionProcess]]:
        return (
            db.query(AdoptionProcess)
            .options(joinedload(AdoptionProcess.steps))
            .filter(AdoptionProcess.adoptant_id == adoptant_id)
            .all()
        )

    def get_processes_for_shelter(self, db: Session, shelter_id: int) -> list[type[AdoptionProcess]]:
        return (
            db.query(AdoptionProcess)
            .options(joinedload(AdoptionProcess.steps))
            .join(Animal, AdoptionProcess.animal_id == Animal.id)
            .join(Refuge, Animal.refuge_id == Refuge.id)
            .filter(Refuge.shelter_id == shelter_id)
            .all()
        )

    def count_processes_for_shelter(self, db: Session, shelter_id: int) -> int:
        return (
            db.query(AdoptionProcess)
            .join(Animal, AdoptionProcess.animal_id == Animal.id)
            .join(Refuge, Animal.refuge_id == Refuge.id)
            .filter(Refuge.shelter_id == shelter_id)
            .count()
        )

    def mark_rejected(self, db: Session, process: AdoptionProcess) -> AdoptionProcess:
        process.status = AdoptionProcessStatusEnum.REJECTED
        db.commit()
        db.refresh(process)
        return process

    def mark_completed(self, db: Session, process: AdoptionProcess) -> AdoptionProcess:
        from datetime import date
        process.status = AdoptionProcessStatusEnum.COMPLETED
        process.end_date = date.today()
        db.commit()
        db.refresh(process)
        return process