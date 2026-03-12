from sqlalchemy.orm import Session
from typing import Optional

from app.models.shelter_member import RoleEnum
from app.repositories.shelter_member_repo import ShelterMemberRepository
from app.repositories.shelter_repo import ShelterRepository
from app.schemas.shelter_member_schema import ShelterMemberCreate, ShelterMemberResponse, ShelterMemberInfo


class ShelterMemberService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = ShelterMemberRepository(db)

    def create_member(self, user_id: int, shelter_id: int, rol: RoleEnum) -> ShelterMemberResponse:
        member = self.repo.create_member(user_id, shelter_id, rol)
        return ShelterMemberResponse.model_validate(member)

    def get_by_user(self, user_id: int) -> Optional[ShelterMemberInfo]:
        member = self.repo.get_by_user(user_id)
        if member:
            return ShelterMemberInfo(
                    name=member.shelter.name,
                    shelter_code=member.shelter.code,
                    role=member.role,
                    join_date=member.join_date,
                )
        return None

    def create_manager_member(self, user_id: int, shelter_id: int) -> ShelterMemberResponse:
        return self.create_member(user_id, shelter_id, RoleEnum.MANAGER)

    def create_volunteer_member(self, user_id: int, shelter_code: str) -> ShelterMemberResponse:
        """Create a new volunteer member for a given shelter"""
        shelter = ShelterRepository().get_by_code(self.db, shelter_code)
        if not shelter:
            raise ValueError(f"Shelter with code {shelter_code} not found")
        return self.create_member(user_id, shelter.id, RoleEnum.VOLUNTEER)