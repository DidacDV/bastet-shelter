import pytest
from unittest.mock import MagicMock, patch
from datetime import date, datetime

from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError
from app.services.animal_service import AnimalService
from app.schemas.animals_schema.animals_schema import AnimalCreate, AnimalUpdate
from app.models.animal.animal import AnimalTypeEnum


def _mock_animal(**overrides):
    animal = MagicMock()
    animal.id = overrides.get("id", 100)
    animal.name = overrides.get("name", "Fluffy")
    animal.link_name = overrides.get("link_name", "fluffy")
    animal.birth_date = overrides.get("birth_date", date(2026, 1, 1))
    animal.arrival_date = overrides.get("arrival_date", None)
    animal.description = overrides.get("description", "A cute cat")
    animal.breed = overrides.get("breed", "Siamese")
    animal.animal_type = overrides.get("animal_type", AnimalTypeEnum.CAT)
    animal.in_adoption = overrides.get("in_adoption", False)
    animal.refuge_id = overrides.get("refuge_id", 10)
    animal.traits = overrides.get("traits", [])
    animal.images = overrides.get("images", [])
    animal.refuge = MagicMock()
    animal.refuge.name = overrides.get("refuge_name", "Main Refuge")
    animal.refuge.shelter = None
    return animal


def _mock_animal_with_shelter(**overrides):
    """Animal whose refuge has a shelter set up (needed for public detail)."""
    animal = _mock_animal(**overrides)
    shelter = MagicMock()
    shelter.link_name = overrides.get("shelter_link_name", "my-shelter")
    shelter.name = overrides.get("shelter_name", "My Shelter")
    animal.refuge.shelter = shelter
    return animal


@pytest.fixture
def service():
    db = MagicMock()
    s = AnimalService(db)
    s.animal_repo = MagicMock()
    s.refuge_repo = MagicMock()
    s.trait_repo = MagicMock()
    s.process_repo = MagicMock()
    s.animal_image_repo = MagicMock()
    s.adoption_process_service = MagicMock()
    s.shift_task_repo = MagicMock()
    s.process_repo.get_process_ids_for_animal.return_value = []
    s.animal_repo.link_name_exists_in_shelter.return_value = False
    return s

def test_register_animal_success(service):
    shelter_id = 1
    data = AnimalCreate(
        name="Fluffy",
        birth_date=date(2026, 1, 1),
        description="A cute cat",
        breed="Siamese",
        animal_type=AnimalTypeEnum.CAT,
        refuge_id=10,
        trait_ids=[]
    )

    mock_refuge = MagicMock()
    mock_refuge.id = 10
    mock_refuge.shelter_id = shelter_id
    service.refuge_repo.get_by_id.return_value = mock_refuge

    mock_animal = _mock_animal(
        id=100,
        name=data.name,
        birth_date=data.birth_date,
        description=data.description,
        breed=data.breed,
        animal_type=data.animal_type,
        in_adoption=data.in_adoption,
        refuge_id=data.refuge_id,
    )

    service.animal_repo.create.return_value = mock_animal

    result = service.register_animal(data, shelter_id)

    assert result.id == 100
    assert result.name == "Fluffy"
    assert result.link_name == "fluffy"
    service.animal_repo.create.assert_called_once()
    service.animal_repo.link_name_exists_in_shelter.assert_called()


def test_register_animal_wrong_shelter(service):
    shelter_id = 1
    data = AnimalCreate(
        name="Fluffy",
        birth_date=date(2026, 1, 1),
        description="A cute cat",
        breed="Siamese",
        animal_type=AnimalTypeEnum.CAT,
        refuge_id=10,
        trait_ids=[]
    )

    mock_refuge = MagicMock()
    mock_refuge.shelter_id = 2
    service.refuge_repo.get_by_id.return_value = mock_refuge

    with pytest.raises(AuthorizationError, match="Refuge does not belong to this shelter"):
        service.register_animal(data, shelter_id)


def test_get_animals_success(service):
    refuge_id = 10
    service.refuge_repo.get_by_id.return_value = MagicMock()

    mock_animal = _mock_animal(refuge_id=refuge_id)

    service.animal_repo.get_by_refuge.return_value = [mock_animal]

    result = service.get_animals(refuge_id)

    assert len(result) == 1
    assert result[0].name == "Fluffy"
    service.animal_repo.get_by_refuge.assert_called_once_with(service.db, refuge_id)


def test_set_in_adoption(service):
    animal_id = 100
    mock_animal = _mock_animal(id=animal_id, in_adoption=False)

    service.animal_repo.get_by_id.return_value = mock_animal

    mock_updated = _mock_animal(id=animal_id, in_adoption=True)

    service.animal_repo.update_adoption_status.return_value = mock_updated

    result = service.set_in_adoption(animal_id, background_tasks=MagicMock())

    assert result.in_adoption is True
    service.animal_repo.update_adoption_status.assert_called_once_with(service.db, animal_id, True)


def test_get_animal_by_id(service):
    animal_id = 100
    mock_animal = _mock_animal(id=animal_id)

    service.animal_repo.get_by_id.return_value = mock_animal

    result = service.get_animal_by_id(animal_id)

    assert result.id == animal_id
    assert result.name == "Fluffy"
    service.animal_repo.get_by_id.assert_called_with(service.db, animal_id)


def test_get_animals_refuge_not_found(service):
    service.refuge_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError, match="Refuge not found"):
        service.get_animals(999)


def test_set_in_adoption_animal_not_found(service):
    service.animal_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError, match="Animal not found"):
        service.get_animal_by_id(999)


def test_get_animal_by_id_not_found(service):
    service.animal_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError, match="Animal not found"):
        service.get_animal_by_id(999)

def test_get_animal_public_detail_success(service):
    animal = _mock_animal_with_shelter(id=100)
    service.animal_repo.get_by_id.return_value = animal

    result = service.get_animal_public_detail(100)

    assert result.id == 100
    assert result.name == "Fluffy"
    assert result.shelter_link_name == "my-shelter"
    service.animal_repo.get_by_id.assert_called_once_with(service.db, 100)


def test_get_animal_public_detail_not_found(service):
    service.animal_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError, match="Animal not found"):
        service.get_animal_public_detail(999)

def test_get_animal_public_detail_by_link_name_success(service):
    animal = _mock_animal_with_shelter(id=100, link_name="fluffy", shelter_link_name="my-shelter")
    service.animal_repo.get_by_link_names.return_value = animal

    result = service.get_animal_public_detail_by_link_name("my-shelter", "fluffy")

    assert result.id == 100
    assert result.link_name == "fluffy"
    service.animal_repo.get_by_link_names.assert_called_once_with(service.db, "my-shelter", "fluffy")


def test_get_animal_public_detail_by_link_name_not_found(service):
    service.animal_repo.get_by_link_names.return_value = None

    with pytest.raises(NotFoundError, match="Animal not found"):
        service.get_animal_public_detail_by_link_name("shelter-x", "unknown")

def test_update_animal_success(service):
    shelter_id = 1
    animal_id = 100
    mock_animal = _mock_animal(id=animal_id, refuge_id=10)
    mock_refuge = MagicMock()
    mock_refuge.shelter_id = shelter_id

    service.animal_repo.get_by_id.return_value = mock_animal
    service.refuge_repo.get_by_id.return_value = mock_refuge

    updated_animal = _mock_animal(id=animal_id, name="UpdatedName")
    service.animal_repo.update.return_value = updated_animal

    data = AnimalUpdate(name="UpdatedName")
    result = service.update_animal(animal_id, data, shelter_id)

    assert result.name == "UpdatedName"
    service.animal_repo.update.assert_called_once()


def test_update_animal_not_found(service):
    service.animal_repo.get_by_id.return_value = None

    data = AnimalUpdate(name="X")
    with pytest.raises(NotFoundError, match="Animal not found"):
        service.update_animal(999, data, shelter_id=1)


def test_update_animal_wrong_shelter(service):
    mock_animal = _mock_animal(id=100, refuge_id=10)
    mock_refuge = MagicMock()
    mock_refuge.shelter_id = 99  # different shelter

    service.animal_repo.get_by_id.return_value = mock_animal
    service.refuge_repo.get_by_id.return_value = mock_refuge

    data = AnimalUpdate(name="X")
    with pytest.raises(AuthorizationError, match="Not authorized to manage this animal"):
        service.update_animal(100, data, shelter_id=1)

def test_delete_animal_success(service):
    shelter_id = 1
    animal_id = 100
    mock_animal = _mock_animal(id=animal_id, refuge_id=10)
    mock_refuge = MagicMock()
    mock_refuge.shelter_id = shelter_id

    service.animal_repo.get_by_id.return_value = mock_animal
    service.refuge_repo.get_by_id.return_value = mock_refuge

    service.delete_animal(animal_id, shelter_id)

    service.animal_repo.delete.assert_called_once_with(service.db, animal_id)


def test_delete_animal_not_found(service):
    service.animal_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError, match="Animal not found"):
        service.delete_animal(999, shelter_id=1)


def test_delete_animal_wrong_shelter(service):
    mock_animal = _mock_animal(id=100, refuge_id=10)
    mock_refuge = MagicMock()
    mock_refuge.shelter_id = 99

    service.animal_repo.get_by_id.return_value = mock_animal
    service.refuge_repo.get_by_id.return_value = mock_refuge

    with pytest.raises(AuthorizationError, match="Not authorized to manage this animal"):
        service.delete_animal(100, shelter_id=1)

def test_get_all_animals_short_info(service):
    today = date.today()
    row = MagicMock()
    row.id = 1
    row.name = "Mia"
    row.birth_date = date(today.year - 3, today.month, today.day)
    row.in_adoption = True
    row.pending_shift_tasks = 2
    row.refuge_name = "Refuge A"
    row.image_url = "http://img.url/mia.jpg"

    service.animal_repo.get_all_short_info.return_value = [row]

    result = service.get_all_animals_short_info(shelter_id=1)

    assert len(result) == 1
    assert result[0].name == "Mia"
    assert result[0].age == 3
    assert result[0].in_adoption is True
    service.animal_repo.get_all_short_info.assert_called_once_with(service.db, 1)

def test_get_portal_animals_short_info(service):
    today = date.today()
    row = MagicMock()
    row.id = 2
    row.name = "Leo"
    row.birth_date = date(today.year - 2, today.month, today.day)
    row.refuge_name = "Refuge B"
    row.shelter_name = "Shelter B"
    row.image_url = None
    row.animal_type = MagicMock()
    row.animal_type.value = "dog"

    service.animal_repo.get_portal_short_info.return_value = ([row], 1)

    result, total = service.get_portal_animals_short_info(province_id="08")

    assert len(result) == 1
    assert result[0].name == "Leo"
    assert result[0].age == 2
    assert result[0].animal_type == "DOG"
    assert total == 1
    service.animal_repo.get_portal_short_info.assert_called_once_with(service.db, "08", 0, None)

def test_create_short_info_list(service):
    today = date.today()
    row = MagicMock()
    row.id = 5
    row.name = "Pepe"
    row.birth_date = date(today.year - 1, today.month, today.day)
    row.in_adoption = False
    row.pending_shift_tasks = 0
    row.refuge_name = "Refuge Z"
    row.image_url = None

    result = service.create_short_info_list([row])

    assert len(result) == 1
    assert result[0].id == 5
    assert result[0].name == "Pepe"
    assert result[0].age == 1

def test_get_pending_tasks_for_animal_not_found(service):
    service.animal_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError, match="Animal not found"):
        service.get_pending_tasks_for_animal(999)

def test_upload_image_max_images_raises(service):
    shelter_id = 1
    animal_id = 100
    mock_animal = _mock_animal(id=animal_id, refuge_id=10)
    mock_refuge = MagicMock()
    mock_refuge.shelter_id = shelter_id

    service.animal_repo.get_by_id.return_value = mock_animal
    service.refuge_repo.get_by_id.return_value = mock_refuge
    service.animal_image_repo.get_image_count.return_value = 5  # MAX_IMAGES reached

    mock_file = MagicMock()
    with pytest.raises(BusinessLogicError, match="Cannot upload more than"):
        service.upload_image(animal_id, mock_file, shelter_id)


def test_delete_image_success(service):
    shelter_id = 1
    animal_id = 100
    image_id = 200

    mock_animal = _mock_animal(id=animal_id, refuge_id=10)
    mock_refuge = MagicMock()
    mock_refuge.shelter_id = shelter_id

    service.animal_repo.get_by_id.return_value = mock_animal
    service.refuge_repo.get_by_id.return_value = mock_refuge

    mock_image = MagicMock()
    mock_image.animal_id = animal_id
    mock_image.cloudinary_public_id = "public/id/abc"
    service.animal_image_repo.get_image_by_id.return_value = mock_image

    with patch("app.services.animal_service.cloudinary_uploader.destroy") as mock_destroy:
        service.delete_image(animal_id, image_id, shelter_id)
        mock_destroy.assert_called_once_with("public/id/abc")

    service.animal_image_repo.delete_image.assert_called_once_with(service.db, mock_image)


def test_delete_image_not_found(service):
    shelter_id = 1
    animal_id = 100

    mock_animal = _mock_animal(id=animal_id, refuge_id=10)
    mock_refuge = MagicMock()
    mock_refuge.shelter_id = shelter_id

    service.animal_repo.get_by_id.return_value = mock_animal
    service.refuge_repo.get_by_id.return_value = mock_refuge
    service.animal_image_repo.get_image_by_id.return_value = None

    with pytest.raises(NotFoundError, match="Image not found"):
        service.delete_image(animal_id, 999, shelter_id)


def test_delete_image_belongs_to_different_animal(service):
    shelter_id = 1
    animal_id = 100

    mock_animal = _mock_animal(id=animal_id, refuge_id=10)
    mock_refuge = MagicMock()
    mock_refuge.shelter_id = shelter_id

    service.animal_repo.get_by_id.return_value = mock_animal
    service.refuge_repo.get_by_id.return_value = mock_refuge

    mock_image = MagicMock()
    mock_image.animal_id = 999  # belongs to a different animal
    service.animal_image_repo.get_image_by_id.return_value = mock_image

    with pytest.raises(NotFoundError, match="Image not found"):
        service.delete_image(animal_id, 200, shelter_id)

def test_set_in_adoption_to_false_triggers_cancel(service):
    animal_id = 100
    mock_animal = _mock_animal(id=animal_id, in_adoption=True)
    service.animal_repo.get_by_id.return_value = mock_animal

    updated_animal = _mock_animal(id=animal_id, in_adoption=False)
    service.animal_repo.update_adoption_status.return_value = updated_animal

    bg_tasks = MagicMock()
    result = service.set_in_adoption(animal_id, background_tasks=bg_tasks)

    # cancel_all_active_for_animal must have been called
    service.adoption_process_service.cancel_all_active_for_animal.assert_called_once_with(
        animal_id, bg_tasks
    )
    assert result.in_adoption is False

def test_build_adoption_url_not_in_adoption(service):
    animal = _mock_animal(in_adoption=False)
    result = service._build_adoption_url(animal)
    assert result is None


def test_build_adoption_url_no_shelter(service):
    animal = _mock_animal(in_adoption=True)
    animal.refuge.shelter = None
    result = service._build_adoption_url(animal)
    assert result is None


def test_build_adoption_url_returns_url(service):
    animal = _mock_animal(in_adoption=True)
    shelter = MagicMock()
    shelter.link_name = "cool-shelter"
    animal.refuge.shelter = shelter
    animal.link_name = "fluffy"

    with patch("app.services.animal_service.settings") as mock_settings:
        mock_settings.PORTAL_BASE_URL = "https://portal.example.com"
        result = service._build_adoption_url(animal)

    assert result == "https://portal.example.com/adopt/cool-shelter/fluffy"