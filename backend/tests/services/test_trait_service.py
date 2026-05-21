import pytest
from unittest.mock import MagicMock

from app.core.exceptions import AuthorizationError, BusinessLogicError, NotFoundError
from app.models.trait import Trait
from app.services.trait_service import TraitService


@pytest.fixture
def service():
    db = MagicMock()
    s = TraitService(db)
    s.trait_repo = MagicMock()
    return s


def test_delete_trait_success(service):
    trait_id = 1
    shelter_id = 1
    mock_trait = MagicMock(spec=Trait)
    mock_trait.shelter_id = shelter_id

    service.trait_repo.get_by_id.return_value = mock_trait
    service.trait_repo.is_used_by_animal.return_value = False

    service.delete_trait(trait_id, shelter_id)

    service.trait_repo.delete.assert_called_once_with(service.db, trait_id)


def test_delete_trait_not_found(service):
    service.trait_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError):
        service.delete_trait(1, 1)


def test_delete_trait_wrong_shelter(service):
    mock_trait = MagicMock(spec=Trait)
    mock_trait.shelter_id = 2
    service.trait_repo.get_by_id.return_value = mock_trait

    with pytest.raises(AuthorizationError):
        service.delete_trait(1, 1)


def test_delete_trait_used_by_animal(service):
    mock_trait = MagicMock(spec=Trait)
    mock_trait.shelter_id = 1
    service.trait_repo.get_by_id.return_value = mock_trait
    service.trait_repo.is_used_by_animal.return_value = True

    with pytest.raises(BusinessLogicError) as excinfo:
        service.delete_trait(1, 1)

    assert "animal" in excinfo.value.message.lower()
    service.trait_repo.delete.assert_not_called()
