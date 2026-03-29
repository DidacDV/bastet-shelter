import pytest
from unittest.mock import MagicMock
from app.services.dashboard_service import DashboardService

@pytest.fixture
def service():
    db = MagicMock()
    s = DashboardService(db)
    s.animal_repo = MagicMock()
    s.member_repo = MagicMock()
    return s

def test_get_dashboard(service):
    shelter_id = 1
    service.animal_repo.count_by_shelter.return_value = 10
    service.member_repo.count_volunteers.return_value = 5

    result = service.get_dashboard(shelter_id)

    assert result.animal_count == 10
    assert result.volunteer_count == 5
    service.animal_repo.count_by_shelter.assert_called_once_with(service.db, shelter_id)
    service.member_repo.count_volunteers.assert_called_once_with(service.db, shelter_id)
