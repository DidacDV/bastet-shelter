from sqlalchemy.orm import Session
from app.models.animal.animal import Animal
from app.models.animal.animal_image import AnimalImage
from app.repositories.generic_repo import BaseRepository


class AnimalImageRepository(BaseRepository[AnimalImage]):
    def __init__(self, db: Session):
        super().__init__(Animal)
        self.db = db

    # --- Image methods ---

    def get_image_count(self, db: Session, animal_id: int) -> int:
        return db.query(AnimalImage).filter(AnimalImage.animal_id == animal_id).count()

    def add_image(self, db: Session, animal_id: int, url: str, cloudinary_public_id: str, order: int) -> AnimalImage:
        image = AnimalImage(
            animal_id=animal_id,
            url=url,
            cloudinary_public_id=cloudinary_public_id,
            order=order
        )
        db.add(image)
        db.commit()
        db.refresh(image)
        return image

    def get_image_by_id(self, db: Session, image_id: int) -> AnimalImage | None:
        return db.query(AnimalImage).filter(AnimalImage.id == image_id).first()

    def delete_image(self, db: Session, image: AnimalImage) -> None:
        db.delete(image)
        db.commit()