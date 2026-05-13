import pytest
from unittest.mock import MagicMock
from datetime import date

from app.core.exceptions import NotFoundError, AuthorizationError
from app.services.animal_service import AnimalService
from app.schemas.animals_schema.animals_schema import AnimalCreate
from app.models.animal.animal import AnimalTypeEnum


@pytest.fixture
def service():
    db = MagicMock()
    s = AnimalService(db)
    s.animal_repo = MagicMock()
    s.refuge_repo = MagicMock()
    s.trait_repo = MagicMock()
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

    mock_animal = MagicMock()
    mock_animal.id = 100
    mock_animal.name = data.name
    mock_animal.birth_date = data.birth_date
    mock_animal.arrival_date = None
    mock_animal.description = data.description
    mock_animal.breed = data.breed
    mock_animal.animal_type = data.animal_type
    mock_animal.in_adoption = data.in_adoption
    mock_animal.refuge_id = data.refuge_id
    mock_animal.traits = []
    mock_animal.image_url = "http://example.com/image.jpg"
    mock_animal.refuge.name = "Main Refuge"

    service.animal_repo.create.return_value = mock_animal

    result = service.register_animal(data, shelter_id)

    assert result.id == 100
    assert result.name == "Fluffy"
    service.animal_repo.create.assert_called_once()


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

    mock_animal = MagicMock()
    mock_animal.id = 100
    mock_animal.name = "Fluffy"
    mock_animal.birth_date = date(2026, 1, 1)
    mock_animal.arrival_date = None
    mock_animal.description = "A cute cat"
    mock_animal.breed = "Siamese"
    mock_animal.animal_type = AnimalTypeEnum.CAT
    mock_animal.in_adoption = False
    mock_animal.refuge_id = refuge_id
    mock_animal.traits = []
    mock_animal.image_url = "http://example.com/image.jpg"
    mock_animal.refuge.name = "Main Refuge"

    service.animal_repo.get_by_refuge.return_value = [mock_animal]

    result = service.get_animals(refuge_id)

    assert len(result) == 1
    assert result[0].name == "Fluffy"
    service.animal_repo.get_by_refuge.assert_called_once_with(service.db, refuge_id)


def test_set_in_adoption(service):
    animal_id = 100
    mock_animal = MagicMock()
    mock_animal.id = animal_id
    mock_animal.in_adoption = False
    mock_animal.name = "Fluffy"
    mock_animal.description = "A cute cat"
    mock_animal.breed = "Siamese"
    mock_animal.birth_date = date(2026, 1, 1)
    mock_animal.arrival_date = None
    mock_animal.animal_type = AnimalTypeEnum.CAT
    mock_animal.refuge_id = 10
    mock_animal.traits = []
    mock_animal.image_url = "http://example.com/image.jpg"
    mock_animal.refuge.name = "Main Refuge"

    service.animal_repo.get_by_id.return_value = mock_animal

    mock_updated = MagicMock()
    mock_updated.id = animal_id
    mock_updated.in_adoption = True
    mock_updated.name = "Fluffy"
    mock_updated.description = "A cute cat"
    mock_updated.breed = "Siamese"
    mock_updated.birth_date = date(2026, 1, 1)
    mock_updated.arrival_date = None
    mock_updated.animal_type = AnimalTypeEnum.CAT
    mock_updated.refuge_id = 10
    mock_updated.traits = []
    mock_updated.image_url = "http://example.com/image.jpg"
    mock_updated.refuge.name = "Main Refuge"

    service.animal_repo.update_adoption_status.return_value = mock_updated

    result = service.set_in_adoption(animal_id, background_tasks= MagicMock())

    assert result.in_adoption is True
    service.animal_repo.update_adoption_status.assert_called_once_with(service.db, animal_id, True)


def test_get_animal_by_id(service):
    animal_id = 100
    mock_animal = MagicMock()
    mock_animal.id = animal_id
    mock_animal.name = "Fluffy"
    mock_animal.birth_date = date(2026, 1, 1)
    mock_animal.arrival_date = None
    mock_animal.description = "A cute cat"
    mock_animal.breed = "Siamese"
    mock_animal.animal_type = AnimalTypeEnum.CAT
    mock_animal.in_adoption = False
    mock_animal.refuge_id = 10
    mock_animal.traits = []
    mock_animal.image_url = "http://example.com/image.jpg"
    mock_animal.refuge.name = "Main Refuge"

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