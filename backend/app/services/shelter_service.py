from sqlalchemy.orm import Session

from app.models.shelter import Shelter
from app.schemas.shelter_schema import ShelterCreate
from app.repositories.shelter_repo import ShelterRepository
from app.services.shelter_member_service import ShelterMemberService

class ShelterService:
    def __init__(self, repository: ShelterRepository, db: Session):
        self.repository = repository
        self.db = db
        self.member_service = ShelterMemberService(db)


    def create_shelter(self, data: ShelterCreate, user_id: int) -> Shelter:
        """Create a new shelter and add the user who created it as a manager"""
        new_shelter = Shelter(**data.model_dump())
        created_shelter = self.repository.create(self.db, new_shelter)

        self.member_service.create_manager_member(user_id, created_shelter.id)
        return created_shelter

    def get_shelter(self, code: str) -> Shelter:
        shelter = self.repository.get_by_code(self.db, code)
        if not shelter:
            raise ValueError(f"Shelter with code {code} not found")
        return shelter