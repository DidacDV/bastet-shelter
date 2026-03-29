import pytest
from unittest.mock import MagicMock
from app.services.task_service import TaskService
from app.schemas.task_schema.task_schema import TaskCreate

@pytest.fixture
def service():
    db = MagicMock()
    s = TaskService(db)
    s.task_repo = MagicMock()
    return s

def test_create_task(service):
    data = TaskCreate(title="Clean cages", description="Clean all cages", num_people=2)
    shelter_id = 1
    
    mock_task = MagicMock()
    mock_task.id = 1
    mock_task.title = data.title
    mock_task.description = data.description
    mock_task.num_people = data.num_people
    mock_task.shelter_id = shelter_id
    
    service.task_repo.create.return_value = mock_task

    result = service.create_task(data, shelter_id)

    assert result.id == 1
    assert result.title == "Clean cages"
    assert result.num_people == 2
    assert result.shelter_id == 1
    service.task_repo.create.assert_called_once()

def test_get_tasks(service):
    shelter_id = 1
    mock_task = MagicMock()
    mock_task.id = 1
    mock_task.title = "Task 1"
    mock_task.description = "Desc 1"
    mock_task.num_people = 1
    mock_task.shelter_id = shelter_id
    
    service.task_repo.get_by_shelter.return_value = [mock_task]

    result = service.get_tasks(shelter_id)

    assert len(result) == 1
    assert result[0].title == "Task 1"
    service.task_repo.get_by_shelter.assert_called_once_with(service.db, shelter_id)
