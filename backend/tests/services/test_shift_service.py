import pytest
from unittest.mock import MagicMock
from datetime import datetime, date
from app.services.shift_service import ShiftService
from app.schemas.shift_schema.shift_schema import ShiftCreate
from app.models.task.task import TaskStatusEnum

@pytest.fixture
def service():
    db = MagicMock()
    s = ShiftService(db)
    s.member_repo = MagicMock()
    s.shift_repo = MagicMock()
    s.participant_repo = MagicMock()
    s.shift_task_repo = MagicMock()
    s.task_repo = MagicMock()
    s.animal_repo = MagicMock()
    s.refuge_repo = MagicMock()
    return s

def test_create_shift_success(service):
    # Setup
    refuge_id = 1
    shelter_id = 1
    data = ShiftCreate(
        start_time=datetime(2023, 10, 10, 8, 0),
        end_time=datetime(2023, 10, 10, 12, 0),
        day=date(2023, 10, 10)
    )
    
    mock_refuge = MagicMock()
    mock_refuge.id = refuge_id
    mock_refuge.shelter_id = shelter_id
    service.refuge_repo.get_by_id.return_value = mock_refuge
    
    mock_shift = MagicMock()
    mock_shift.id = 1
    mock_shift.start_time = data.start_time
    mock_shift.end_time = data.end_time
    mock_shift.day = data.day
    mock_shift.refuge_id = refuge_id
    service.shift_repo.create.return_value = mock_shift

    result = service.create_shift(data, refuge_id, shelter_id)

    assert result.id == 1
    assert result.refuge_id == refuge_id
    service.shift_repo.create.assert_called_once()

def test_create_shift_refuge_not_found(service):
    service.refuge_repo.get_by_id.return_value = None
    data = ShiftCreate(start_time=datetime.now(), end_time=datetime.now(), day=date.today())

    with pytest.raises(ValueError, match="Refuge not found or does not belong to this shelter"):
        service.create_shift(data, 1, 1)

def test_get_shifts(service):
    refuge_id = 1
    mock_refuge = MagicMock()
    service.refuge_repo.get_by_id.return_value = mock_refuge
    
    mock_shift = MagicMock()
    mock_shift.id = 1
    mock_shift.day = date(2023, 10, 10)
    service.shift_repo.get_by_refuge.return_value = [mock_shift]

    result = service.get_shifts(refuge_id, day=date(2023, 10, 10))

    assert len(result) == 1
    service.shift_repo.get_by_refuge.assert_called_once_with(service.db, refuge_id)

def test_join_shift_success(service):
    shift_id = 1
    user_id = 1
    mock_volunteer = MagicMock()
    mock_volunteer.id = 10
    service.member_repo.get_by_user.return_value = mock_volunteer
    
    mock_participant = MagicMock()
    mock_participant.id = 100
    mock_participant.shift_id = shift_id
    mock_participant.volunteer_id = 10
    service.participant_repo.create.return_value = mock_participant

    result = service.join_shift(shift_id, user_id)

    assert result.id == 100
    assert result.volunteer_id == 10
    service.participant_repo.create.assert_called_once()

def test_leave_shift(service):
    shift_id = 1
    user_id = 1
    mock_volunteer = MagicMock()
    mock_volunteer.id = 10
    service.member_repo.get_by_user.return_value = mock_volunteer
    
    mock_participant = MagicMock()
    mock_participant.id = 100
    mock_participant.volunteer_id = 10
    service.participant_repo.get_by_shift.return_value = [mock_participant]

    service.leave_shift(shift_id, user_id)

    service.participant_repo.delete.assert_called_once_with(service.db, 100)

def test_add_task_to_shift_success(service):
    shift_id = 1
    task_id = 1
    mock_shift = MagicMock()
    mock_shift.id = shift_id
    mock_shift.day = date.today()
    service.shift_repo.get_by_id.return_value = mock_shift
    
    mock_task = MagicMock()
    mock_task.id = task_id
    service.task_repo.get_by_id.return_value = mock_task
    
    mock_shift_task = MagicMock()
    mock_shift_task.id = 50
    mock_shift_task.status = TaskStatusEnum.NOT_COMPLETED
    mock_shift_task.assigned_date = mock_shift.day
    mock_shift_task.shift_id = shift_id
    mock_shift_task.task_id = task_id
    mock_shift_task.participant_id = None
    mock_shift_task.animal_id = None
    
    mock_task_resp = MagicMock()
    mock_task_resp.id = task_id
    mock_task_resp.title = "Task 1"
    mock_task_resp.description = "Desc 1"
    mock_task_resp.num_people = 1
    mock_task_resp.shelter_id = 1
    mock_shift_task.task = mock_task_resp
    
    service.shift_task_repo.create.return_value = mock_shift_task

    result = service.add_task_to_shift(shift_id, task_id)

    assert result.id == 50
    service.shift_task_repo.create.assert_called_once()

def test_assign_task(service):
    shift_task_id = 1
    participant_id = 10
    mock_updated_task = MagicMock()
    mock_updated_task.id = shift_task_id
    mock_updated_task.status = TaskStatusEnum.NOT_COMPLETED
    mock_updated_task.assigned_date = date.today()
    mock_updated_task.shift_id = 1
    mock_updated_task.task_id = 1
    mock_updated_task.participant_id = participant_id
    mock_updated_task.animal_id = None
    
    mock_task_resp = MagicMock()
    mock_task_resp.id = 1
    mock_task_resp.title = "Task 1"
    mock_task_resp.description = "Desc 1"
    mock_task_resp.num_people = 1
    mock_task_resp.shelter_id = 1
    mock_updated_task.task = mock_task_resp
    
    service.shift_task_repo.assign_participant.return_value = mock_updated_task

    result = service.assign_task(shift_task_id, participant_id)

    assert result.participant_id == participant_id
    service.shift_task_repo.assign_participant.assert_called_once_with(service.db, shift_task_id, participant_id)

def test_complete_task(service):
    shift_task_id = 1
    mock_updated_task = MagicMock()
    mock_updated_task.id = shift_task_id
    mock_updated_task.status = TaskStatusEnum.COMPLETED
    mock_updated_task.assigned_date = date.today()
    mock_updated_task.shift_id = 1
    mock_updated_task.task_id = 1
    mock_updated_task.participant_id = None
    mock_updated_task.animal_id = None
    
    mock_task_resp = MagicMock()
    mock_task_resp.id = 1
    mock_task_resp.title = "Task 1"
    mock_task_resp.description = "Desc 1"
    mock_task_resp.num_people = 1
    mock_task_resp.shelter_id = 1
    mock_updated_task.task = mock_task_resp
    
    service.shift_task_repo.update_status.return_value = mock_updated_task

    result = service.complete_task(shift_task_id)

    assert result.status == TaskStatusEnum.COMPLETED
    service.shift_task_repo.update_status.assert_called_once_with(service.db, shift_task_id, TaskStatusEnum.COMPLETED)

def test_get_shifts_refuge_not_found(service):
    service.refuge_repo.get_by_id.return_value = None
    with pytest.raises(ValueError, match="Refuge not found"):
        service.get_shifts(999)

def test_join_shift_volunteer_not_found(service):
    service.member_repo.get_by_user.return_value = None
    with pytest.raises(ValueError, match="Volunteer record not found"):
        service.join_shift(1, 1)

def test_leave_shift_volunteer_not_found(service):
    service.member_repo.get_by_user.return_value = None
    with pytest.raises(ValueError, match="Volunteer record not found"):
        service.leave_shift(1, 1)

def test_add_task_to_shift_not_found(service):
    service.shift_repo.get_by_id.return_value = None
    with pytest.raises(ValueError, match="Shift not found"):
        service.add_task_to_shift(999, 1)

def test_add_task_to_shift_template_not_found(service):
    service.shift_repo.get_by_id.return_value = MagicMock()
    service.task_repo.get_by_id.return_value = None
    with pytest.raises(ValueError, match="Task template not found"):
        service.add_task_to_shift(1, 999)

def test_add_task_to_shift_animal_not_found(service):
    service.shift_repo.get_by_id.return_value = MagicMock()
    service.task_repo.get_by_id.return_value = MagicMock()
    service.animal_repo.get_by_id.return_value = None
    with pytest.raises(ValueError, match="Animal not found"):
        service.add_task_to_shift(1, 1, animal_id=999)

def test_assign_task_not_found(service):
    service.shift_task_repo.assign_participant.return_value = None
    with pytest.raises(ValueError, match="ShiftTask not found"):
        service.assign_task(999, 1)

def test_complete_task_not_found(service):
    service.shift_task_repo.update_status.return_value = None
    with pytest.raises(ValueError, match="ShiftTask not found"):
        service.complete_task(999)
