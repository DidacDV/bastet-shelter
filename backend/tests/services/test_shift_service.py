import pytest
from unittest.mock import MagicMock
from datetime import datetime, date

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.services.shift_service import ShiftService
from app.schemas.shift_schema.shift_schema import ShiftCreate
from app.models.task.task import TaskStatusEnum

def _mock_shift(shift_id=1, shelter_id=1, refuge_id=1):
    m = MagicMock()
    m.id = shift_id
    m.shelter_id = shelter_id
    m.refuge_id = refuge_id
    m.day = date(2023, 10, 10)
    m.start_time = datetime(2023, 10, 10, 8, 0)
    m.end_time = datetime(2023, 10, 10, 12, 0)
    m.max_participants = 4
    m.current_participants = 1
    m.participants = []
    return m


def _mock_task(task_id=1, shelter_id=1):
    m = MagicMock()
    m.id = task_id
    m.title = "Task Title"
    m.description = "Task Desc"
    m.num_people = 1
    m.shelter_id = shelter_id
    return m


def _mock_participant(participant_id=100, shift_id=1, member_id=10):
    m = MagicMock()
    m.id = participant_id
    m.shift_id = shift_id
    m.member_id = member_id
    m.volunteer_id = member_id
    m.name = "John"
    m.last_name_1 = "Doe"
    m.shift_tasks = []
    return m


def _mock_shift_task(shift_task_id=1, shift_id=1, task_id=1, participant_id=None, status=TaskStatusEnum.NOT_COMPLETED):
    m = MagicMock()
    m.id = shift_task_id
    m.shift_id = shift_id
    m.task_id = task_id
    m.assigned_date = date(2023, 10, 10)
    m.status = status
    m.participant_id = participant_id
    m.animal_id = None

    m.task = _mock_task(task_id)
    m.participant = _mock_participant(participant_id, shift_id) if participant_id else None
    m.animal = None
    return m


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
    data = ShiftCreate(
        start_time=datetime(2023, 10, 10, 8, 0),
        end_time=datetime(2023, 10, 10, 12, 0),
        day=date(2023, 10, 10),
        task_ids=[]
    )

    mock_refuge = MagicMock()
    mock_refuge.id = 1
    mock_refuge.shelter_id = 1
    service.refuge_repo.get_by_id.return_value = mock_refuge
    service.shift_repo.create.return_value = _mock_shift()

    result = service.create_shift(data, refuge_id=1, shelter_id=1)

    assert result.id == 1
    service.shift_repo.create.assert_called_once()


def test_create_shift_refuge_not_found(service):
    service.refuge_repo.get_by_id.return_value = None
    data = ShiftCreate(start_time=datetime.now(), end_time=datetime.now(), day=date.today(), task_ids=[])

    with pytest.raises(NotFoundError, match="Refuge not found"):
        service.create_shift(data, 1, 1)


def test_get_shifts(service):
    service.refuge_repo.get_by_id.return_value = MagicMock()
    service.shift_repo.get_by_refuge.return_value = [_mock_shift()]

    result = service.get_shifts(refuge_id=1, day=date(2023, 10, 10))

    assert len(result) == 1
    service.shift_repo.get_by_refuge.assert_called_once()


def test_join_shift_success(service):
    service.shift_repo.get_by_id.return_value = _mock_shift()
    service.member_repo.get_by_user.return_value = MagicMock(id=10)
    service.participant_repo.create.return_value = _mock_participant(participant_id=100)

    result = service.join_shift(shift_id=1, user_id=1)

    assert result.id == 100
    service.participant_repo.create.assert_called_once()


def test_join_shift_volunteer_not_found(service):
    service.shift_repo.get_by_id.return_value = _mock_shift()
    service.member_repo.get_by_user.return_value = None

    with pytest.raises(NotFoundError, match="Member record not found"):
        service.join_shift(1, 1)


def test_join_shift_max_capacity(service):
    m_shift = _mock_shift()
    m_shift.max_participants = 2
    m_shift.current_participants = 2
    service.shift_repo.get_by_id.return_value = m_shift

    with pytest.raises(BusinessLogicError, match="maximum capacity"):
        service.join_shift(1, 1)


def test_leave_shift(service):
    mock_auth = MagicMock()
    mock_auth.user.id = 1

    service.member_repo.get_by_user.return_value = MagicMock(id=10)

    m_participant = _mock_participant(participant_id=100)
    m_task = _mock_shift_task(participant_id=100, status=TaskStatusEnum.COMPLETED)
    m_participant.shift_tasks = [m_task]

    service.participant_repo.get_by_shift_and_member.return_value = m_participant

    service.leave_shift(1, mock_auth)

    assert m_task.participant_id is None
    assert m_task.status == TaskStatusEnum.NOT_COMPLETED
    service.participant_repo.delete.assert_called_once_with(service.db, 100)


def test_leave_shift_volunteer_not_found(service):
    service.member_repo.get_by_user.return_value = None
    with pytest.raises(NotFoundError, match="Member record not found"):
        service.leave_shift(1, MagicMock())


def test_leave_shift_not_participating(service):
    service.member_repo.get_by_user.return_value = MagicMock(id=10)
    service.participant_repo.get_by_shift_and_member.return_value = None

    with pytest.raises(BusinessLogicError, match="not participating"):
        service.leave_shift(1, MagicMock())


def test_add_task_to_shift_success(service):
    service.shift_repo.get_by_id.return_value = _mock_shift()
    service.task_repo.get_by_id.return_value = _mock_task()
    service.shift_task_repo.create.return_value = _mock_shift_task(shift_task_id=50)

    result = service.add_task_to_shift(shift_id=1, task_id=1, shelter_id=1)

    assert result.id == 50
    service.shift_task_repo.create.assert_called_once()


def test_add_task_to_shift_not_found(service):
    service.shift_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError, match="Shift not found"):
        service.add_task_to_shift(999, 1, 1)


def test_add_task_to_shift_template_not_found(service):
    service.shift_repo.get_by_id.return_value = _mock_shift()
    service.task_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError, match="Task 999 not found"):
        service.add_task_to_shift(1, 999, 1)


def test_add_task_to_shift_animal_not_found(service):
    service.shift_repo.get_by_id.return_value = _mock_shift()
    service.task_repo.get_by_id.return_value = _mock_task()
    service.animal_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError, match="Animal not found"):
        service.add_task_to_shift(1, 1, 1, animal_id=999)


def test_assign_task(service):
    service.shift_task_repo.get_by_id.return_value = _mock_shift_task()
    service.shift_repo.get_by_id.return_value = _mock_shift()
    service.participant_repo.get_by_id.return_value = _mock_participant(participant_id=10)

    service.shift_task_repo.assign_participant.return_value = _mock_shift_task(participant_id=10)

    result = service.assign_task(shift_task_id=1, participant_id=10, shelter_id=1)

    assert result.participant.id == 10
    service.shift_task_repo.assign_participant.assert_called_once_with(service.db, 1, 10)


def test_assign_task_not_found(service):
    service.shift_task_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError, match="ShiftTask not found"):
        service.assign_task(999, 1, 1)


def test_assign_task_participant_not_found(service):
    service.shift_task_repo.get_by_id.return_value = _mock_shift_task()
    service.shift_repo.get_by_id.return_value = _mock_shift()
    service.participant_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError, match="Participant not found"):
        service.assign_task(1, 999, 1)


def test_assign_task_participant_wrong_shift(service):
    service.shift_task_repo.get_by_id.return_value = _mock_shift_task(shift_id=1)
    service.shift_repo.get_by_id.return_value = _mock_shift(shift_id=1)
    service.participant_repo.get_by_id.return_value = _mock_participant(shift_id=2)

    with pytest.raises(BusinessLogicError, match="Participant is not assigned to this shift"):
        service.assign_task(1, 10, 1)


def test_complete_task(service):
    mock_auth = MagicMock()
    mock_auth.shelter_id = 1
    mock_auth.is_manager = True

    service.shift_task_repo.get_by_id.return_value = _mock_shift_task(participant_id=10)
    service.shift_repo.get_by_id.return_value = _mock_shift()

    service.shift_task_repo.update_status.return_value = _mock_shift_task(
        participant_id=10,
        status=TaskStatusEnum.COMPLETED
    )

    result = service.complete_task(1, mock_auth)

    assert result.status == TaskStatusEnum.COMPLETED
    service.shift_task_repo.update_status.assert_called_once_with(service.db, 1, TaskStatusEnum.COMPLETED)


def test_complete_task_not_found(service):
    service.shift_task_repo.get_by_id.return_value = None
    with pytest.raises(NotFoundError, match="ShiftTask not found"):
        service.complete_task(999, MagicMock())


def test_complete_task_unassigned(service):
    mock_auth = MagicMock(shelter_id=1)
    service.shift_task_repo.get_by_id.return_value = _mock_shift_task(participant_id=None)
    service.shift_repo.get_by_id.return_value = _mock_shift()

    with pytest.raises(BusinessLogicError, match="Cannot complete a task that is not assigned"):
        service.complete_task(1, mock_auth)


def test_unassign_task_success(service):
    mock_auth = MagicMock(shelter_id=1, is_manager=True)

    service.shift_task_repo.get_by_id.return_value = _mock_shift_task(participant_id=10)
    service.shift_repo.get_by_id.return_value = _mock_shift()

    service.shift_task_repo.unassign_participant.return_value = _mock_shift_task(participant_id=None)

    result = service.unassign_task(1, mock_auth)

    assert result.participant is None
    service.shift_task_repo.unassign_participant.assert_called_once_with(service.db, 1)


def test_uncomplete_task_success(service):
    mock_auth = MagicMock(shelter_id=1, is_manager=True)

    service.shift_task_repo.get_by_id.return_value = _mock_shift_task(
        participant_id=10,
        status=TaskStatusEnum.COMPLETED
    )
    service.shift_repo.get_by_id.return_value = _mock_shift()

    service.shift_task_repo.update_status.return_value = _mock_shift_task(
        participant_id=10,
        status=TaskStatusEnum.NOT_COMPLETED
    )

    result = service.uncomplete_task(1, mock_auth)

    assert result.status == TaskStatusEnum.NOT_COMPLETED
    service.shift_task_repo.update_status.assert_called_once_with(service.db, 1, TaskStatusEnum.NOT_COMPLETED)