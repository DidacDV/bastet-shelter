import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.routers.task_router import get_task_service, get_shift_service
from app.core.dependencies.role_dependencies import get_current_user, require_manager, require_shelter_manager

mock_user = MagicMock()
mock_user.id = 1
mock_auth = MagicMock()
mock_auth.user = mock_user
mock_auth.shelter_id = 1
mock_auth.role = "MANAGER"


def _task_response(**overrides):
    data = {
        "id": 1,
        "title": "Walk the dogs",
        "description": "Morning walk for all dogs",
        "num_people": 2,
        "shelter_id": 1,
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_task_service():
    return MagicMock()


@pytest.fixture
def mock_shift_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_task_service, mock_shift_service):
    app.dependency_overrides[get_task_service] = lambda: mock_task_service
    app.dependency_overrides[get_shift_service] = lambda: mock_shift_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[require_shelter_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_user] = lambda: mock_auth
    yield
    app.dependency_overrides = {}


def test_create_task_success(client, mock_task_service):
    mock_task_service.create_task.return_value = _task_response()

    response = client.post("/tasks/", json={
        "title": "Walk the dogs",
        "description": "Morning walk for all dogs",
        "num_people": 2,
    })

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["title"] == "Walk the dogs"
    mock_task_service.create_task.assert_called_once()


def test_create_task_error(client, mock_task_service):
    mock_task_service.create_task.side_effect = ValueError("Invalid data")

    response = client.post("/tasks/", json={
        "title": "Walk the dogs",
        "description": "Morning walk",
        "num_people": 2,
    })

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_tasks_success(client, mock_task_service):
    mock_task_service.get_tasks.return_value = [_task_response()]

    response = client.get("/tasks/")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["tasks"]) == 1
    mock_task_service.get_tasks.assert_called_once_with(1)


def test_get_tasks_empty(client, mock_task_service):
    mock_task_service.get_tasks.return_value = []

    response = client.get("/tasks/")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["tasks"] == []


def test_delete_task_success(client, mock_task_service):
    response = client.delete("/tasks/1")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_task_service.delete_task.assert_called_once_with(1, 1)


def test_delete_task_error(client, mock_task_service):
    mock_task_service.delete_task.side_effect = ValueError("Task is already removed")

    response = client.delete("/tasks/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_update_task_success(client, mock_task_service):
    mock_task_service.update_task.return_value = _task_response(title="Updated Walk")

    response = client.put("/tasks/1", json={
        "title": "Updated Walk",
        "description": "Morning walk for all dogs",
        "num_people": 2,
    })

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["title"] == "Updated Walk"
    mock_task_service.update_task.assert_called_once()


def test_update_task_error(client, mock_task_service):
    mock_task_service.update_task.side_effect = ValueError("Task is already removed")

    response = client.put("/tasks/999", json={
        "title": "Updated Walk",
        "description": "Morning walk",
        "num_people": 2,
    })

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_my_tasks_success(client, mock_shift_service):
    mock_shift_service.get_my_tasks.return_value = []

    response = client.get("/tasks/me")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["my_shift_tasks"] == []
    mock_shift_service.get_my_tasks.assert_called_once_with(1)


def test_get_task_service(db):
    from app.routers.task_router import get_task_service
    from app.services.task_service import TaskService
    service = get_task_service(db)
    assert isinstance(service, TaskService)
