from sqlalchemy.orm import Session

from app.repositories.adoption.adoption_process_repo import AdoptionProcessRepository
from app.repositories.animal_repo import AnimalRepository
from app.repositories.shelter_member_repo import ShelterMemberRepository
from app.schemas.dashboard_schema import ShelterDashboardResponse


class DashboardService:
    def __init__(self, db: Session):
        self.db = db
        self.animal_repo = AnimalRepository(db)
        self.member_repo = ShelterMemberRepository(db)
        self.adoption_process_repo = AdoptionProcessRepository(db)

    def get_dashboard(self, shelter_id: int) -> ShelterDashboardResponse:
        return ShelterDashboardResponse(
            animal_count=self.animal_repo.count_by_shelter(self.db, shelter_id),
            volunteer_count=self.member_repo.count_volunteers(self.db, shelter_id),
            active_adoption_count=self.adoption_process_repo.count_processes_for_shelter(self.db, shelter_id)
        )