import pytest
from unittest.mock import MagicMock, patch
from typing import List

from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError
from app.models.advertisement import Advertisement, AdCategoryEnum
from app.services.advertisement_service import AdvertisementService
from app.schemas.advertisement_schema import AdvertisementCreate


@pytest.fixture
def service():
    db = MagicMock()
    s = AdvertisementService(db)
    s.shelter_repo = MagicMock()
    s.advertisement_repo = MagicMock()
    s.geo_repo = MagicMock()
    return s


def test_create_advertisement_success(service):
    data = AdvertisementCreate(
        title="Need Kibble",
        description="Looking for dog food",
        category=AdCategoryEnum.FOOD,
        province_name="BARCELONA",
        image_url=None
    )

    mock_province = MagicMock()
    mock_province.id = 5
    service.geo_repo.get_province_by_name.return_value = mock_province

    mock_ad = MagicMock(spec=Advertisement)
    mock_ad.id = 1
    mock_ad.title = "Need Kibble"
    mock_ad.description = "Looking for dog food"
    mock_ad.category = AdCategoryEnum.FOOD
    mock_ad.province_id = 5
    mock_ad.shelter_id = 10
    service.advertisement_repo.create.return_value = mock_ad

    with patch("app.schemas.advertisement_schema.AdvertisementDetail.model_validate") as mock_validate:
        service.create_advertisement(data, shelter_id=10)
        mock_validate.assert_called_once_with(mock_ad)

    service.geo_repo.get_province_by_name.assert_called_once_with(service.db, "BARCELONA")
    service.advertisement_repo.create.assert_called_once()


def test_create_advertisement_province_not_found(service):
    data = AdvertisementCreate(
        title="Need Kibble",
        description="Looking for dog food",
        category=AdCategoryEnum.FOOD,
        province_name="INVALID_PROVINCE",
        image_url=None
    )
    service.geo_repo.get_province_by_name.return_value = None

    with pytest.raises(NotFoundError):
        service.create_advertisement(data, shelter_id=10)


def test_get_my_advertisements(service):
    mock_ad = MagicMock(spec=Advertisement)
    service.advertisement_repo.get_by_shelter.return_value = [mock_ad]

    with patch("app.schemas.advertisement_schema.AdvertisementSummary.model_validate") as mock_validate:
        service.get_my_advertisements(shelter_id=10)
        mock_validate.assert_called_once_with(mock_ad)


def test_get_advertisements_filter_all(service):
    mock_province = MagicMock()
    mock_province.id = 5
    service.geo_repo.get_province_by_name.return_value = mock_province

    ad_self = MagicMock(spec=Advertisement)
    ad_self.shelter_id = 10

    ad_other = MagicMock(spec=Advertisement)
    ad_other.shelter_id = 20

    service.advertisement_repo.get_active_advertisements.return_value = ([ad_self, ad_other], 2)

    with patch("app.schemas.advertisement_schema.AdvertisementSummary.model_validate") as mock_validate:
        result, total = service.get_advertisements(province_name="BARCELONA", category=AdCategoryEnum.FOOD, shelter_id=10)
        mock_validate.assert_called_once_with(ad_other)


def test_get_advertisements_province_not_found(service):
    service.geo_repo.get_province_by_name.return_value = None
    result, total = service.get_advertisements(province_name="INVALID")
    assert result == []
    assert total == 0


def test_get_advertisement_by_id_success(service):
    mock_ad = MagicMock(spec=Advertisement)
    service.advertisement_repo.get_by_id.return_value = mock_ad

    with patch("app.schemas.advertisement_schema.AdvertisementDetail.model_validate") as mock_validate:
        service.get_advertisement_by_id(1)
        mock_validate.assert_called_once_with(mock_ad)


def test_get_advertisement_by_id_not_found(service):
    service.advertisement_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError):
        service.get_advertisement_by_id(1)


def test_deactivate_advertisement_success(service):
    mock_ad = MagicMock(spec=Advertisement)
    mock_ad.shelter_id = 10
    mock_ad.is_active = True
    service.advertisement_repo.get_by_id.return_value = mock_ad

    with patch("app.schemas.advertisement_schema.AdvertisementDetail.model_validate") as mock_validate:
        service.deactivate_advertisement(ad_id=1, shelter_id=10)
        assert mock_ad.is_active is False
        service.db.commit.assert_called_once()
        service.db.refresh.assert_called_once_with(mock_ad)


def test_deactivate_advertisement_not_found(service):
    service.advertisement_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError):
        service.deactivate_advertisement(ad_id=1, shelter_id=10)


def test_deactivate_advertisement_unauthorized(service):
    mock_ad = MagicMock(spec=Advertisement)
    mock_ad.shelter_id = 20
    service.advertisement_repo.get_by_id.return_value = mock_ad

    with pytest.raises(AuthorizationError):
        service.deactivate_advertisement(ad_id=1, shelter_id=10)


@patch("app.services.advertisement_service.cloudinary_uploader")
def test_upload_image_success(mock_cloudinary, service):
    mock_ad = MagicMock(spec=Advertisement)
    mock_ad.shelter_id = 10
    mock_ad.image_public_id = "old_pid"
    service.advertisement_repo.get_by_id.return_value = mock_ad

    mock_file = MagicMock()
    mock_file.file = b"filebytes"

    mock_cloudinary.upload.return_value = {
        "secure_url": "https://cloudinary.com/new_img.jpg",
        "public_id": "new_pid"
    }

    with patch("app.schemas.advertisement_schema.AdvertisementDetail.model_validate") as mock_validate:
        service.upload_image(ad_id=1, file=mock_file, shelter_id=10)

        mock_cloudinary.destroy.assert_called_once_with("old_pid")
        mock_cloudinary.upload.assert_called_once()
        assert mock_ad.image_url == "https://cloudinary.com/new_img.jpg"
        assert mock_ad.image_public_id == "new_pid"
        service.db.commit.assert_called_once()


def test_upload_image_not_found(service):
    service.advertisement_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError):
        service.upload_image(ad_id=1, file=MagicMock(), shelter_id=10)


def test_upload_image_unauthorized(service):
    mock_ad = MagicMock(spec=Advertisement)
    mock_ad.shelter_id = 20
    service.advertisement_repo.get_by_id.return_value = mock_ad

    with pytest.raises(AuthorizationError):
        service.upload_image(ad_id=1, file=MagicMock(), shelter_id=10)


@patch("app.services.advertisement_service.cloudinary_uploader")
def test_delete_image_success(mock_cloudinary, service):
    mock_ad = MagicMock(spec=Advertisement)
    mock_ad.shelter_id = 10
    mock_ad.image_public_id = "pid_to_delete"
    service.advertisement_repo.get_by_id.return_value = mock_ad

    with patch("app.schemas.advertisement_schema.AdvertisementDetail.model_validate") as mock_validate:
        service.delete_image(ad_id=1, shelter_id=10)

        mock_cloudinary.destroy.assert_called_once_with("pid_to_delete")
        assert mock_ad.image_url is None
        assert mock_ad.image_public_id is None
        service.db.commit.assert_called_once()


def test_delete_image_not_found(service):
    service.advertisement_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError):
        service.delete_image(ad_id=1, shelter_id=10)


def test_delete_image_unauthorized(service):
    mock_ad = MagicMock(spec=Advertisement)
    mock_ad.shelter_id = 20
    service.advertisement_repo.get_by_id.return_value = mock_ad

    with pytest.raises(AuthorizationError):
        service.delete_image(ad_id=1, shelter_id=10)


def test_delete_image_no_image_error(service):
    mock_ad = MagicMock(spec=Advertisement)
    mock_ad.shelter_id = 10
    mock_ad.image_public_id = None
    service.advertisement_repo.get_by_id.return_value = mock_ad

    with pytest.raises(BusinessLogicError):
        service.delete_image(ad_id=1, shelter_id=10)