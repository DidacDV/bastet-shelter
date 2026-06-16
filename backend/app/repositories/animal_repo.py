from sqlalchemy import func, select
from sqlalchemy.orm import Session
from app.models.adoption.adoption_process import AdoptionProcess, AdoptionProcessStatusEnum
from app.models.animal.animal import Animal
from app.models.animal.animal_image import AnimalImage
from app.models.refuge import Refuge
from app.models.shelter import Shelter
from app.models.task.shift_task import ShiftTask
from app.models.task.task import TaskStatusEnum
from app.repositories.generic_repo import BaseRepository

primary_image = (
    select(AnimalImage.url)
    .where(AnimalImage.animal_id == Animal.id)
    .order_by(AnimalImage.order.asc())
    .limit(1)
    .correlate(Animal)
    .scalar_subquery()
)

class AnimalRepository(BaseRepository[Animal]):
    def __init__(self, db: Session):
        super().__init__(Animal)
        self.db = db

    def get_by_refuge(self, db: Session, refuge_id: int) -> list[Animal]:
        return db.query(Animal).filter(Animal.refuge_id == refuge_id).all()

    def get_by_link_names(
        self,
        db: Session,
        shelter_link_name: str,
        animal_link_name: str,
    ) -> Animal | None:
        return (
            db.query(Animal)
            .join(Refuge, Animal.refuge_id == Refuge.id)
            .join(Shelter, Refuge.shelter_id == Shelter.id)
            .filter(Shelter.link_name == shelter_link_name, Animal.link_name == animal_link_name)
            .first()
        )

    def link_name_exists_in_shelter(
        self,
        db: Session,
        shelter_id: int,
        link_name: str,
        exclude_animal_id: int | None = None,
    ) -> bool:
        query = (
            db.query(Animal.id)
            .join(Refuge, Animal.refuge_id == Refuge.id)
            .filter(Refuge.shelter_id == shelter_id, Animal.link_name == link_name)
        )
        if exclude_animal_id is not None:
            query = query.filter(Animal.id != exclude_animal_id)
        return query.first() is not None

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

    def get_all_short_info(self, db: Session, shelter_id: int):
        return (
            db.query(
                Animal.id,
                Animal.name,
                Animal.birth_date,
                Animal.in_adoption,
                Refuge.name.label("refuge_name"),
                func.count(ShiftTask.id).label("pending_shift_tasks"),
                primary_image.label("image_url"),
            )
            .join(Refuge, Animal.refuge_id == Refuge.id)
            .filter(Refuge.shelter_id == shelter_id)
            .outerjoin(
                ShiftTask,
                (ShiftTask.animal_id == Animal.id) &
                (ShiftTask.status == TaskStatusEnum.NOT_COMPLETED)
            )
            .group_by(Animal.id, Refuge.name)
            .all()
        )

    def get_portal_short_info(self, db: Session, province_id: str, skip: int = 0, limit: int | None = None):
        has_active_adoption_process = (
            select(AdoptionProcess.id)
            .where(
                AdoptionProcess.animal_id == Animal.id,
                AdoptionProcess.status == AdoptionProcessStatusEnum.ACTIVE,
            )
            .correlate(Animal)
            .exists()
        )

        query = (
            db.query(
                Animal.id,
                Animal.name,
                Animal.birth_date,
                Animal.animal_type,
                Refuge.name.label("refuge_name"),
                Shelter.name.label("shelter_name"),
                primary_image.label("image_url"),
            )
            .join(Refuge, Animal.refuge_id == Refuge.id)
            .join(Shelter, Refuge.shelter_id == Shelter.id)
            .filter(Animal.in_adoption == True)
            .filter(~has_active_adoption_process)
        )

        query = query.filter(Refuge.province_id == province_id)
        query = query.group_by(Animal.id, Refuge.name, Shelter.name)

        total = query.count()

        if skip:
            query = query.offset(skip)
        if limit is not None:
            query = query.limit(limit)

        return query.all(), total