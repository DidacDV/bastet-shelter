import pytest
from unittest.mock import MagicMock
from fastapi import status
from app.main import app
from app.routers.shift_router import get_shift_service
from app.core.dependencies.role_dependencies import get_current_user, require_manager, require_volunteer

mock_user = MagicMock()
mock_user.id = 1
mock_auth = MagicMock()
mock_auth.user = mock_user
mock_auth.shelter_id = 1
mock_auth.role = "MANAGER"


def _shift_response(**overrides):
    data = {
        "id": 1,
        "start_time": "2026-05-25T09:00:00",
        "end_time": "2026-05-25T13:00:00",
        "day": "2026-05-25",
        "refuge_id": 1,
        "max_participants": 5,
        "current_participants": 0,
    }
    data.update(overrides)
    return data


def _shift_detail_response(**overrides):
    data = {
        "id": 1,
        "start_time": "2026-05-25T09:00:00",
        "end_time": "2026-05-25T13:00:00",
        "day": "2026-05-25",
        "refuge_id": 1,
        "max_participants": 5,
        "current_participants": 0,
        "participants": [],
        "tasks": [],
        "is_joined": False,
    }
    data.update(overrides)
    return data


def _shift_task_response(**overrides):
    data = {
        "id": 1,
        "status": "NOT_COMPLETED",
        "assigned_date": "2026-05-25",
        "shift_id": 1,
        "task_id": 1,
        "task": {
            "id": 1,
            "title": "Walk",
            "description": "Morning walk",
            "num_people": 1,
            "shelter_id": 1,
        },
        "participant": None,
        "animal": None,
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_service):
    app.dependency_overrides[get_shift_service] = lambda: mock_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_user] = lambda: mock_auth
    app.dependency_overrides[require_volunteer] = lambda: mock_auth
    yield
    app.dependency_overrides = {}


def test_create_shift_success(client, mock_service):
    mock_service.create_shift.return_value = _shift_response()

    response = client.post("/shifts/?refuge_id=1", json={
        "start_time": "2026-05-25T09:00:00",
        "end_time": "2026-05-25T13:00:00",
        "day": "2026-05-25",
    })

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["id"] == 1
    mock_service.create_shift.assert_called_once()


def test_create_shift_error(client, mock_service):
    mock_service.create_shift.side_effect = ValueError("Refuge is invalid")

    response = client.post("/shifts/?refuge_id=999", json={
        "start_time": "2026-05-25T09:00:00",
        "end_time": "2026-05-25T13:00:00",
        "day": "2026-05-25",
    })

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_shifts_success(client, mock_service):
    mock_service.get_shifts.return_value = [_shift_response()]

    response = client.get("/shifts/?refuge_id=1")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["shifts"]) == 1
    mock_service.get_shifts.assert_called_once()


def test_get_shift_detail_success(client, mock_service):
    mock_service.get_shift_detail.return_value = _shift_detail_response()

    response = client.get("/shifts/1")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["id"] == 1
    mock_service.get_shift_detail.assert_called_once_with(1, 1, user_id=1)


def test_get_shift_detail_error(client, mock_service):
    mock_service.get_shift_detail.side_effect = ValueError("Shift is unavailable")

    response = client.get("/shifts/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_join_shift_success(client, mock_service):
    mock_service.join_shift.return_value = {
        "id": 1, "shift_id": 1, "user_id": 1
    }

    response = client.post("/shifts/1/join")

    assert response.status_code == status.HTTP_200_OK
    mock_service.join_shift.assert_called_once_with(1, 1)


def test_join_shift_error(client, mock_service):
    mock_service.join_shift.side_effect = ValueError("Shift is full")

    response = client.post("/shifts/1/join")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_leave_shift_success(client, mock_service):
    response = client.delete("/shifts/1/leave")

    assert response.status_code == status.HTTP_200_OK
    mock_service.leave_shift.assert_called_once()


def test_add_task_to_shift_success(client, mock_service):
    mock_service.add_task_to_shift.return_value = _shift_task_response()

    response = client.post("/shifts/1/tasks?task_id=1")

    assert response.status_code == status.HTTP_200_OK
    mock_service.add_task_to_shift.assert_called_once_with(1, 1, 1, None)


def test_add_task_to_shift_error(client, mock_service):
    mock_service.add_task_to_shift.side_effect = ValueError("Task is invalid")

    response = client.post("/shifts/1/tasks?task_id=999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_remove_task_from_shift_success(client, mock_service):
    response = client.delete("/shifts/tasks/1")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_service.remove_task_from_shift.assert_called_once_with(1, 1)


def test_update_shift_success(client, mock_service):
    mock_service.update_shift.return_value = _shift_detail_response(
        start_time="2026-05-25T10:00:00"
    )

    response = client.patch("/shifts/1", json={"start_time": "2026-05-25T10:00:00"})

    assert response.status_code == status.HTTP_200_OK
    mock_service.update_shift.assert_called_once()


def test_assign_task_success(client, mock_service):
    mock_service.assign_task.return_value = _shift_task_response()

    response = client.patch("/shifts/tasks/1/assign?participant_id=2")

    assert response.status_code == status.HTTP_200_OK
    mock_service.assign_task.assert_called_once_with(1, 2, 1)


def test_unassign_task_success(client, mock_service):
    mock_service.unassign_task.return_value = _shift_task_response()

    response = client.patch("/shifts/tasks/1/unassign")

    assert response.status_code == status.HTTP_200_OK
    mock_service.unassign_task.assert_called_once()


def test_complete_task_success(client, mock_service):
    mock_service.complete_task.return_value = _shift_task_response(status="COMPLETED")

    response = client.patch("/shifts/tasks/1/complete")

    assert response.status_code == status.HTTP_200_OK
    mock_service.complete_task.assert_called_once()


def test_uncomplete_task_success(client, mock_service):
    mock_service.uncomplete_task.return_value = _shift_task_response()

    response = client.patch("/shifts/tasks/1/uncomplete")

    assert response.status_code == status.HTTP_200_OK
    mock_service.uncomplete_task.assert_called_once()


def test_copy_week_success(client, mock_service):
    mock_service.copy_shifts_week.return_value = [_shift_response()]

    response = client.post(
        "/shifts/copy-week?refuge_id=1&source_week_start=2026-05-18&target_week_start=2026-05-25"
    )

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["shifts"]) == 1
    mock_service.copy_shifts_week.assert_called_once()


def test_clear_day_success(client, mock_service):
    mock_service.clear_day.return_value = 2

    response = client.delete("/shifts/clear-day?refuge_id=1&day=2026-05-25")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["deleted"] == 2
    mock_service.clear_day.assert_called_once()


def test_clear_week_success(client, mock_service):
    mock_service.clear_week.return_value = 5

    response = client.delete("/shifts/clear-week?refuge_id=1&week_start=2026-05-25")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["deleted"] == 5
    mock_service.clear_week.assert_called_once()


def test_delete_shift_success(client, mock_service):
    response = client.delete("/shifts/1")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_service.delete_shift.assert_called_once_with(1, 1)


def test_delete_shift_error(client, mock_service):
    mock_service.delete_shift.side_effect = ValueError("Shift is unavailable")

    response = client.delete("/shifts/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_shift_service(db):
    from app.routers.shift_router import get_shift_service
    from app.services.shift_service import ShiftService
    service = get_shift_service(db)
    assert isinstance(service, ShiftService)
