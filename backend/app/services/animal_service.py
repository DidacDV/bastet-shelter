from datetime import date
from fastapi import UploadFile
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError
from app.models.animal.animal import Animal
from app.repositories.adoption.adoption_process_repo import AdoptionProcessRepository
from app.services.adoption_process_service import AdoptionProcessService
from app.repositories.animal_image_repo import AnimalImageRepository
from app.repositories.animal_repo import AnimalRepository
from app.repositories.refuge_repo import RefugeRepository
from app.repositories.trait_repo import TraitRepository
from app.schemas.animals_schema.animals_image_schema import AnimalImageResponse
from app.schemas.animals_schema.animals_schema import AnimalCreate, AnimalResponse, AnimalShortInfo, AnimalUpdate, \
    AnimalPublicShortInfo

import cloudinary
import cloudinary.uploader as cloudinary_uploader

MAX_IMAGES = 5

cloudinary.config(
    cloud_name=settings.CLOUDINARY_CLOUD_NAME,
    api_key=settings.CLOUDINARY_API_KEY,
    api_secret=settings.CLOUDINARY_API_SECRET,
)

class AnimalService:
    def __init__(self, db: Session):
        self.db = db
        self.animal_repo = AnimalRepository(db)
        self.refuge_repo = RefugeRepository(db)
        self.trait_repo = TraitRepository(db)
        self.animal_image_repo = AnimalImageRepository(db)
        self.process_repo = AdoptionProcessRepository(db)
        self.adoption_process_service = AdoptionProcessService(db)

    def _to_response(self, animal: Animal) -> AnimalResponse:
        process_ids = self.process_repo.get_process_ids_for_animal(self.db, animal.id)

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
            adoption_processes=process_ids,
            images=[
                AnimalImageResponse(
                    id=img.id,
                    url=img.url,
                    cloudinary_public_id=img.cloudinary_public_id,
                    order=img.order
                )
                for img in sorted(animal.images, key=lambda x: x.order)
            ],
        )

    def _validate_animal_ownership(self, animal_id: int, shelter_id: int) -> Animal:
        """helper to fetch an animal and verify the shelter manager owns it"""
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise NotFoundError("Animal not found")

        refuge = self.refuge_repo.get_by_id(self.db, animal.refuge_id)
        if not refuge or refuge.shelter_id != shelter_id:
            raise AuthorizationError("Not authorized to manage this animal")

        return animal

    def register_animal(self, data: AnimalCreate, shelter_id: int) -> AnimalResponse:
        refuge = self.refuge_repo.get_by_id(self.db, data.refuge_id)
        if not refuge:
            raise NotFoundError("Refuge not found")
        if refuge.shelter_id != shelter_id:
            raise AuthorizationError("Refuge does not belong to this shelter")

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
        refuge = self.refuge_repo.get_by_id(self.db, refuge_id)
        if not refuge:
            raise NotFoundError("Refuge not found")
        animals = self.animal_repo.get_by_refuge(self.db, refuge_id)
        return [self._to_response(a) for a in animals]

    def set_in_adoption(self, animal_id: int) -> AnimalResponse:
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise NotFoundError("Animal not found")

        new_status = not animal.in_adoption
        if not new_status:
            self.adoption_process_service.cancel_all_active_for_animal(animal_id)

        updated_animal = self.animal_repo.update_adoption_status(self.db, animal_id, new_status)
        return self._to_response(updated_animal)

    def get_animal_by_id(self, animal_id: int) -> AnimalResponse:
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise NotFoundError("Animal not found")
        return self._to_response(animal)

    def get_all_animals_short_info(self, shelter_id: int) -> list[AnimalShortInfo]:
        results = self.animal_repo.get_all_short_info(self.db, shelter_id)
        return self.create_short_info_list(results)

    def get_portal_animals_short_info(self, province_id: str) -> list[AnimalPublicShortInfo]:
        results = self.animal_repo.get_portal_short_info(self.db, province_id)

        short_info_list = []
        today = date.today()

        for row in results:
            age = today.year - row.birth_date.year - (
                    (today.month, today.day) < (row.birth_date.month, row.birth_date.day)
            )

            short_info_list.append(
                AnimalPublicShortInfo(
                    id=row.id,
                    name=row.name,
                    age=age,
                    refuge_name=row.refuge_name,
                    shelter_name=row.shelter_name,
                    image_url=row.image_url,
                    animal_type=row.animal_type.value.upper()
                )
            )

        return short_info_list

    def create_short_info_list(self, short_info) -> list[AnimalShortInfo]:
        short_info_list = []
        today = date.today()

        for row in short_info:
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
                    refuge_name=row.refuge_name,
                    image_url=row.image_url
                )
            )
        return short_info_list

    def update_animal(self, animal_id: int, data: AnimalUpdate, shelter_id: int) -> AnimalResponse:
        animal = self._validate_animal_ownership(animal_id, shelter_id)
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

    def delete_animal(self, animal_id: int, shelter_id: int) -> None:
        self._validate_animal_ownership(animal_id, shelter_id)
        self.animal_repo.delete(self.db, animal_id)

    #ANIMAL IMAGES REGION
    def upload_image(self, animal_id: int, file: UploadFile, shelter_id: int) -> AnimalImageResponse:
        self._validate_animal_ownership(animal_id, shelter_id)

        current_count = self.animal_image_repo.get_image_count(self.db, animal_id)
        if current_count >= MAX_IMAGES:
            raise BusinessLogicError(f"Cannot upload more than {MAX_IMAGES} images per animal")

        result = cloudinary_uploader.upload(
            file.file,
            asset_folder=f"shelters/{shelter_id}/animals/{animal_id}",
            resource_type="image",
            transformation=[
                {
                    'width': 400,
                    'height': 500,
                    'crop': 'fill',
                    'quality': 'auto',
                    'fetch_format': 'auto'
                }
            ]
        )

        image = self.animal_image_repo.add_image(
            db=self.db,
            animal_id=animal_id,
            url=result["secure_url"],
            cloudinary_public_id=result["public_id"],
            order=current_count
        )

        return AnimalImageResponse(
            id=image.id,
            url=image.url,
            cloudinary_public_id=image.cloudinary_public_id,
            order=image.order
        )

    def delete_image(self, animal_id: int, image_id: int, shelter_id: int) -> None:
        self._validate_animal_ownership(animal_id, shelter_id)

        image = self.animal_image_repo.get_image_by_id(self.db, image_id)
        if not image or image.animal_id != animal_id:
            raise NotFoundError("Image not found")

        cloudinary_uploader.destroy(image.cloudinary_public_id)
        self.animal_image_repo.delete_image(self.db, image)