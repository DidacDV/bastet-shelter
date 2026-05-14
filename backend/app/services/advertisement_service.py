from typing import List, Optional

from fastapi import UploadFile
from sqlalchemy.orm import Session
import cloudinary
from cloudinary import uploader as cloudinary_uploader

from app.core.config import settings
from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError
from app.models.advertisement import AdCategoryEnum
from app.repositories.geo_repo import GeoRepository
from app.schemas.advertisement_schema import AdvertisementCreate, AdvertisementSummary, AdvertisementDetail
from app.repositories.advertisement_repo import AdvertisementRepository
from app.repositories.shelter_repo import ShelterRepository
from app.models.advertisement import Advertisement

MAX_IMAGES = 1

cloudinary.config(
    cloud_name=settings.CLOUDINARY_CLOUD_NAME,
    api_key=settings.CLOUDINARY_API_KEY,
    api_secret=settings.CLOUDINARY_API_SECRET,
)

class AdvertisementService:
    def __init__(self, db: Session):
        self.db = db
        self.shelter_repo = ShelterRepository(db)
        self.advertisement_repo = AdvertisementRepository(db)
        self.geo_repo = GeoRepository(db)

    def create_advertisement(self, data: AdvertisementCreate, shelter_id: int) -> AdvertisementDetail:
        province = self.geo_repo.get_province_by_name(self.db, data.province_name)
        if not province:
            raise NotFoundError(f"Province '{data.province_name}' not found")

        ad_data = data.model_dump(exclude={"province_name"})
        new_ad = Advertisement(**ad_data, province_id=province.id, shelter_id=shelter_id)

        created_ad = self.advertisement_repo.create(self.db, new_ad)
        return AdvertisementDetail.model_validate(created_ad)

    def get_my_advertisements(self, shelter_id: int) -> List[AdvertisementSummary]:
        ads = self.advertisement_repo.get_by_shelter(self.db, shelter_id)
        return [AdvertisementSummary.model_validate(ad) for ad in ads]

    def get_advertisements(
            self, province_name: Optional[str] = None, category: Optional[AdCategoryEnum] = None, shelter_id: Optional[int] = None
    ) -> List[AdvertisementSummary]:

        province_id = None

        if province_name:
            province = self.geo_repo.get_province_by_name(self.db, province_name)
            if not province:
                return []
            province_id = province.id

        ads = self.advertisement_repo.get_active_advertisements(self.db, province_id, category)

        non_self_ads = []
        for ad in ads:
            if ad.shelter_id != shelter_id:
                non_self_ads.append(ad)

        return [AdvertisementSummary.model_validate(ad) for ad in non_self_ads]

    def get_advertisement_by_id(self, ad_id: int) -> AdvertisementDetail:
        ad = self.advertisement_repo.get_by_id(self.db, ad_id)
        if not ad:
            raise NotFoundError("Advertisement not found")
        return AdvertisementDetail.model_validate(ad)

    def deactivate_advertisement(self, ad_id: int, shelter_id: int) -> AdvertisementDetail:
        ad = self.advertisement_repo.get_by_id(self.db, ad_id)
        if not ad:
            raise NotFoundError("Advertisement not found")

        if ad.shelter_id != shelter_id:
            raise AuthorizationError("You do not have permission to modify this advertisement")

        ad.is_active = False
        self.db.commit()
        self.db.refresh(ad)

        return AdvertisementDetail.model_validate(ad)

    def upload_image(self, ad_id: int, file: UploadFile, shelter_id: int) -> AdvertisementDetail:
        ad = self.advertisement_repo.get_by_id(self.db, ad_id)
        if not ad:
            raise NotFoundError("Advertisement not found")
        if ad.shelter_id != shelter_id:
            raise AuthorizationError("You do not have permission to modify this advertisement")

        if ad.image_public_id:
            cloudinary_uploader.destroy(ad.image_public_id)

        #upload to cloudinary
        result = cloudinary_uploader.upload(
            file.file,
            asset_folder=f"shelters/{shelter_id}/advertisements/{ad_id}",
            resource_type="image",
            transformation=[
                {'width': 600, 'height': 600, 'crop': 'fill', 'quality': 'auto', 'fetch_format': 'auto'}
            ]
        )

        #save to db
        ad.image_url = result["secure_url"]
        ad.image_public_id = result["public_id"]
        self.db.commit()
        self.db.refresh(ad)

        return AdvertisementDetail.model_validate(ad)

    def delete_image(self, ad_id: int, shelter_id: int) -> AdvertisementDetail:
        ad = self.advertisement_repo.get_by_id(self.db, ad_id)
        if not ad:
            raise NotFoundError("Advertisement not found")
        if ad.shelter_id != shelter_id:
            raise AuthorizationError("You do not have permission to modify this advertisement")
        if not ad.image_public_id:
            raise BusinessLogicError("This advertisement does not have an image to delete")

        #delete from cloudinary
        cloudinary_uploader.destroy(ad.image_public_id)

        #delete from db
        ad.image_url = None
        ad.image_public_id = None
        self.db.commit()
        self.db.refresh(ad)

        return AdvertisementDetail.model_validate(ad)