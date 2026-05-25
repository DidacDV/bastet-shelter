import pytest
from unittest.mock import MagicMock
from app.core.exceptions import AuthorizationError, BusinessLogicError, NotFoundError
from app.models.task.task import Task
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

def test_delete_task_success(service):
    task_id = 1
    shelter_id = 1
    mock_task = MagicMock(spec=Task)
    mock_task.shelter_id = shelter_id

    service.task_repo.get_by_id.return_value = mock_task
    service.task_repo.is_used_in_shift.return_value = False

    service.delete_task(shelter_id, task_id)

    service.task_repo.delete.assert_called_once_with(service.db, task_id)

def test_delete_task_not_found(service):
    service.task_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError):
        service.delete_task(1, 1)

def test_delete_task_wrong_shelter(service):
    mock_task = MagicMock(spec=Task)
    mock_task.shelter_id = 2
    service.task_repo.get_by_id.return_value = mock_task

    with pytest.raises(AuthorizationError):
        service.delete_task(1, 1)

def test_delete_task_used_in_shift(service):
    mock_task = MagicMock(spec=Task)
    mock_task.shelter_id = 1
    service.task_repo.get_by_id.return_value = mock_task
    service.task_repo.is_used_in_shift.return_value = True

    with pytest.raises(BusinessLogicError) as excinfo:
        service.delete_task(1, 1)

    assert "shift" in excinfo.value.message.lower()
    service.task_repo.delete.assert_not_called()
