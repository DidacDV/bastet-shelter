import pytest
from unittest.mock import MagicMock
from fastapi import HTTPException

from app.core.exceptions import BusinessLogicError, NotFoundError
from app.services.refuge_service import RefugeService
from app.schemas.refuge_schema import RefugeCreate
from app.models.refuge import Refuge

@pytest.fixture
def db():
    return MagicMock()

@pytest.fixture
def refuge_service(db):
    service = RefugeService(db)
    service.refuge_repo = MagicMock()
    return service

def test_create_refuge(refuge_service, db):
    data = RefugeCreate(name="Main Refuge", province_id="08")
    shelter_id = 1
    
    mock_refuge = MagicMock(spec=Refuge)
    mock_refuge.id = 1
    mock_refuge.name = "Main Refuge"
    mock_refuge.shelter_id = shelter_id
    mock_refuge.province = MagicMock()
    mock_refuge.province.id = "08"
    mock_refuge.province.name = "Barcelona"
    
    refuge_service.refuge_repo.create.return_value = mock_refuge
    
    result = refuge_service.create_refuge(data, shelter_id)
    
    assert result.id == 1
    assert result.name == "Main Refuge"
    assert result.province.id == "08"
    refuge_service.refuge_repo.create.assert_called_once()

def test_get_refuges(refuge_service):
    shelter_id = 1
    mock_refuge = MagicMock(spec=Refuge)
    mock_refuge.id = 1
    mock_refuge.name = "Main Refuge"
    mock_refuge.shelter_id = shelter_id
    mock_refuge.province = MagicMock()
    mock_refuge.province.id = "08"
    mock_refuge.province.name = "Barcelona"
    
    refuge_service.refuge_repo.get_by_shelter.return_value = [mock_refuge]
    
    result = refuge_service.get_refuges(shelter_id)
    
    assert len(result) == 1
    assert result[0].id == 1
    refuge_service.refuge_repo.get_by_shelter.assert_called_once_with(refuge_service.db, shelter_id)

def test_delete_refuge_success(refuge_service):
    refuge_id = 1
    shelter_id = 1
    
    mock_refuge = MagicMock(spec=Refuge)
    mock_refuge.id = refuge_id
    mock_refuge.shelter_id = shelter_id
    mock_refuge.animals = []
    mock_refuge.shifts = []
    
    refuge_service.refuge_repo.get_by_id.return_value = mock_refuge
    refuge_service.refuge_repo.get_by_shelter.return_value = [mock_refuge, MagicMock()]
    
    refuge_service.delete_refuge(refuge_id, shelter_id)
    
    refuge_service.refuge_repo.delete.assert_called_once_with(refuge_service.db, refuge_id)

def test_delete_refuge_not_found(refuge_service):
    refuge_service.refuge_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError) as excinfo:
        refuge_service.delete_refuge(1, 1)
    assert excinfo.value.message == "Refuge not found"

def test_delete_refuge_wrong_shelter(refuge_service):
    mock_refuge = MagicMock(spec=Refuge)
    mock_refuge.shelter_id = 2
    refuge_service.refuge_repo.get_by_id.return_value = mock_refuge
    with pytest.raises(NotFoundError) as excinfo:
        refuge_service.delete_refuge(1, 1)
    assert excinfo.value.message == "Refuge not found"

def test_delete_refuge_with_animals(refuge_service):
    mock_refuge = MagicMock(spec=Refuge)
    mock_refuge.shelter_id = 1
    mock_refuge.animals = [MagicMock()]
    refuge_service.refuge_repo.get_by_id.return_value = mock_refuge
    with pytest.raises(BusinessLogicError) as excinfo:
        refuge_service.delete_refuge(1, 1)
    assert "animals" in excinfo.value.message.lower()

def test_delete_refuge_with_shifts(refuge_service):
    mock_refuge = MagicMock(spec=Refuge)
    mock_refuge.shelter_id = 1
    mock_refuge.animals = []
    mock_refuge.shifts = [MagicMock()]
    refuge_service.refuge_repo.get_by_id.return_value = mock_refuge
    with pytest.raises(BusinessLogicError) as excinfo:
        refuge_service.delete_refuge(1, 1)
    assert "shifts" in excinfo.value.message.lower()

def test_delete_refuge_last_refuge(refuge_service):
    mock_refuge = MagicMock(spec=Refuge)
    mock_refuge.id = 1
    mock_refuge.shelter_id = 1
    mock_refuge.animals = []
    mock_refuge.shifts = []

    refuge_service.refuge_repo.get_by_id.return_value = mock_refuge
    refuge_service.refuge_repo.get_by_shelter.return_value = [mock_refuge]
    with pytest.raises(BusinessLogicError) as excinfo:
        refuge_service.delete_refuge(1, 1)
    assert "last refuge" in excinfo.value.message.lower()
