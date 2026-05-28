import pytest
from unittest.mock import MagicMock
from datetime import date

from app.core.exceptions import NotFoundError, AuthorizationError
from app.services.animal_service import AnimalService
from app.schemas.animals_schema.animals_schema import AnimalCreate
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


@pytest.fixture
def service():
    db = MagicMock()
    s = AnimalService(db)
    s.animal_repo = MagicMock()
    s.refuge_repo = MagicMock()
    s.trait_repo = MagicMock()
    s.process_repo = MagicMock()
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

    result = service.set_in_adoption(animal_id, background_tasks= MagicMock())

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