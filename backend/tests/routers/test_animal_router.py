import pytest
from unittest.mock import MagicMock, ANY
from fastapi import status
from app.main import app
from app.routers.animal_router import get_animal_service
from app.core.dependencies.role_dependencies import get_current_user, require_manager
from app.models.user import AuthenticatedUser

mock_user = MagicMock()
mock_user.id = 1
mock_auth = AuthenticatedUser(user=mock_user, role="MANAGER", shelter_id=1)


@pytest.fixture
def mock_service():
    service = MagicMock()
    return service


@pytest.fixture(autouse=True)
def setup_overrides(mock_service):
    app.dependency_overrides[get_animal_service] = lambda: mock_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_user] = lambda: mock_auth
    yield
    app.dependency_overrides = {}


def test_register_animal_success(client, mock_service):
    mock_service.register_animal.return_value = {
        "id": 1, "name": "Buddy", "birth_date": "2026-01-01",
        "arrival_date": None,
        "description": "Desc", "breed": "Breed",
        "animal_type": "DOG", "in_adoption": False, "refuge_id": 1,
        "refuge_name": "Main Refuge",
        "image_url": None,
        "traits": []
    }

    response = client.post("/animals/", json={
        "name": "Buddy", "birth_date": "2026-01-01",
        "description": "Desc", "breed": "Breed",
        "animal_type": "DOG", "refuge_id": 1,
        "refuge_name": "Main Refuge",
        "image_url": None,
        "trait_ids": []
    })

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["name"] == "Buddy"
    mock_service.register_animal.assert_called_once()


def test_register_animal_error(client, mock_service):
    mock_service.register_animal.side_effect = ValueError("Invalid refuge")

    response = client.post("/animals/", json={
        "name": "Buddy", "birth_date": "2026-01-01",
        "description": "Desc", "breed": "Breed",
        "animal_type": "DOG", "refuge_id": 1,
        "refuge_name": "Main Refuge",
        "image_url": None,
        "trait_ids": []
    })

    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert response.json()["detail"] == "Invalid refuge"


def test_get_animals_success(client, mock_service):
    mock_service.get_animals.return_value = [
        {"id": 1, "name": "Buddy", "birth_date": "2026-01-01", "arrival_date": None,
         "description": "Desc", "breed": "Breed",
         "animal_type": "DOG", "in_adoption": False, "refuge_id": 1,
         "refuge_name": "Main Refuge",
         "image_url": None,
         "traits": []}
    ]

    response = client.get("/animals/?refuge_id=1")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()) == 1
    mock_service.get_animals.assert_called_once_with(1)


def test_get_animals_error(client, mock_service):
    mock_service.get_animals.side_effect = ValueError("Refuge not found")

    response = client.get("/animals/?refuge_id=1")

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json()["detail"] == "Refuge not found"


def test_get_animal_detail_success(client, mock_service):
    mock_service.get_animal_by_id.return_value = {
        "id": 1, "name": "Buddy", "birth_date": "2026-01-01", "arrival_date": None,
        "description": "Desc", "breed": "Breed",
        "animal_type": "DOG", "in_adoption": False, "refuge_id": 1,
        "refuge_name": "Main Refuge",
        "image_url": None,
        "traits": []
    }

    response = client.get("/animals/1")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["id"] == 1
    mock_service.get_animal_by_id.assert_called_once_with(1)


def test_get_animal_detail_error(client, mock_service):
    mock_service.get_animal_by_id.side_effect = ValueError("Animal not found")

    response = client.get("/animals/999")

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json()["detail"] == "Animal not found"


def test_get_animal_pending_tasks_success(client, mock_service):
    mock_service.get_pending_tasks_for_animal.return_value = [
        {
            "shift": {
                "id": 1,
                "start_time": "2026-05-25T09:00:00",
                "end_time": "2026-05-25T13:00:00",
                "day": "2026-05-25",
                "refuge_id": 1,
                "max_participants": 5,
                "current_participants": 2,
            },
            "tasks": [
                {
                    "id": 10,
                    "status": "NOT_COMPLETED",
                    "assigned_date": "2026-05-25",
                    "shift_id": 1,
                    "task_id": 3,
                    "task": {
                        "id": 3,
                        "title": "Walk",
                        "description": "Morning walk",
                        "num_people": 1,
                        "shelter_id": 1,
                    },
                    "participant": None,
                    "animal": None,
                }
            ],
        }
    ]

    response = client.get("/animals/1/pending-tasks")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["pending_tasks"]) == 1
    mock_service.get_pending_tasks_for_animal.assert_called_once_with(1, None)


def test_get_animal_pending_tasks_error(client, mock_service):
    mock_service.get_pending_tasks_for_animal.side_effect = ValueError("Animal not found")

    response = client.get("/animals/999/pending-tasks")

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json()["detail"] == "Animal not found"


def test_toggle_adoption_success(client, mock_service):
    mock_service.set_in_adoption.return_value = {
        "id": 1, "name": "Buddy", "birth_date": "2026-01-01", "arrival_date": None,
        "description": "Desc", "breed": "Breed",
        "animal_type": "DOG", "in_adoption": True, "refuge_id": 1,
        "refuge_name": "Main Refuge",
        "image_url": None,
        "traits": []
    }

    response = client.patch("/animals/1/adoption")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["in_adoption"] is True
    mock_service.set_in_adoption.assert_called_once_with(1, ANY)

def test_get_animal_service(db):
    from app.routers.animal_router import get_animal_service
    from app.services.animal_service import AnimalService
    service = get_animal_service(db)
    assert isinstance(service, AnimalService)


def test_toggle_adoption_error(client, mock_service):
    mock_service.set_in_adoption.side_effect = ValueError("Animal not found")

    response = client.patch("/animals/1/adoption")

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json()["detail"] == "Animal not found"