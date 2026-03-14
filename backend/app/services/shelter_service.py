from datetime import date
from typing import Optional
from sqlalchemy.orm import Session

from app.core.security import create_access_token
from app.models.shelter import Shelter
from app.models.shelter_member import RoleEnum, Manager, Volunteer
from app.repositories.shelter_repo import ShelterRepository
from app.repositories.shelter_member_repo import ShelterMemberRepository
from app.schemas.shelter_schema import ShelterCreate, ShelterResponse
from app.schemas.shelter_member_schema import ShelterMemberResponse, ShelterMemberInfo


class ShelterService:
    def __init__(self, db: Session):
        self.db = db
        self.shelter_repo = ShelterRepository()
        self.member_repo = ShelterMemberRepository(db)

    #Shelter
    def create_shelter(self, data: ShelterCreate, user_id: int, user_email: str) -> dict:
        """Creates a new shelter and adds the user as manager"""
        new_shelter = Shelter(**data.model_dump())
        created_shelter = self.shelter_repo.create(self.db, new_shelter)
        self.create_manager_member_by_id(user_id, created_shelter.id)

        new_token = create_access_token(data={"sub": user_email, "role": RoleEnum.MANAGER.value})
        return {
            "shelter": ShelterResponse.model_validate(created_shelter),
            "access_token": new_token,
            "token_type": "bearer"
        }

    def get_shelter(self, code: str) -> Shelter:
        shelter = self.shelter_repo.get_by_code(self.db, code)
        if not shelter:
            raise ValueError(f"Shelter with code {code} not found")
        return shelter

    #Shelter Members
    def join_as_volunteer(self, user_id: int, shelter_code: str, user_email: str) -> dict:
        """Joins a shelter strictly as volunteer and rejects manager codes."""
        shelter = self.shelter_repo.get_by_volunteer_code(self.db, shelter_code)
        if not shelter:
            raise ValueError("Invalid volunteer code")
        self.create_volunteer_member(user_id, shelter_code)
        acc_token = create_access_token(data={"sub": user_email, "role": RoleEnum.VOLUNTEER})
        return {"access_token": acc_token, "token_type": "bearer"}

    def join_as_manager(self, user_id: int, shelter_code: str, user_email: str) -> dict:
        """Joins a shelter strictly as manager and rejects volunteer codes."""
        shelter = self.shelter_repo.get_by_manager_code(self.db, shelter_code)
        if not shelter:
            raise ValueError("Invalid manager code")
        self.create_manager_member_by_id(user_id, shelter.id)
        acc_token = create_access_token(data={"sub": user_email, "role": RoleEnum.MANAGER})
        return {"access_token": acc_token, "token_type": "bearer"}

    def get_by_user(self, user_id: int) -> Optional[ShelterMemberInfo]:
        member = self.member_repo.get_by_user(user_id)
        if member:
            return ShelterMemberInfo(
                name=member.shelter.name,
                role=member.role,
                join_date=member.join_date,
            )
        return None

    def create_volunteer_member_by_id(self, user_id: int, shelter_id: int) -> ShelterMemberResponse:
        member = Volunteer(user_id=user_id, shelter_id=shelter_id, role=RoleEnum.VOLUNTEER, join_date=date.today())
        return ShelterMemberResponse.model_validate(self.member_repo.create(self.db, member))

    def create_manager_member_by_id(self, user_id: int, shelter_id: int) -> ShelterMemberResponse:
        member = Manager(user_id=user_id, shelter_id=shelter_id, role=RoleEnum.MANAGER, join_date=date.today())
        return ShelterMemberResponse.model_validate(self.member_repo.create(self.db, member))

    def create_volunteer_member(self, user_id: int, shelter_code: str) -> ShelterMemberResponse:
        shelter = self.shelter_repo.get_by_volunteer_code(self.db, shelter_code)
        if not shelter:
            raise ValueError(f"Shelter with code {shelter_code} not found")
        return self.create_volunteer_member_by_id(user_id, shelter.id)