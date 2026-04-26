from datetime import date
from typing import Optional
from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError
from app.core.security import create_access_token
from app.core.utils import generate_code
from app.models.refuge import Refuge
from app.models.shelter import Shelter
from app.models.shelter_member import RoleEnum, Manager, Volunteer
from app.models.trait import DEFAULT_TRAITS
from app.repositories.refuge_repo import RefugeRepository
from app.repositories.shelter_repo import ShelterRepository
from app.repositories.shelter_member_repo import ShelterMemberRepository
from app.repositories.trait_repo import TraitRepository
from app.schemas.shelter_schema import ShelterCreate, ShelterResponse, ShelterBasicInfoResponse, ShelterUpdate
from app.schemas.shelter_member_schema import ShelterMemberResponse, ShelterMemberInfo


class ShelterService:
    def __init__(self, db: Session):
        self.db = db
        self.refuge_repo = RefugeRepository(db)
        self.shelter_repo = ShelterRepository(db)
        self.member_repo = ShelterMemberRepository(db)
        self.trait_repo = TraitRepository(db)

    def create_shelter(self, data: ShelterCreate, user_id: int, user_email: str) -> dict:
        new_shelter = Shelter(name=data.name, province_id=data.province_id)
        created_shelter = self.shelter_repo.create(self.db, new_shelter)

        first_refuge = Refuge(name=data.refuge_name, province_id=new_shelter.province_id, shelter_id=created_shelter.id)
        self.refuge_repo.create(self.db, first_refuge)

        self.create_manager_member_by_id(user_id, created_shelter.id)
        new_token = create_access_token(
            data={"sub": user_email, "role": RoleEnum.MANAGER.value, "shelter_id": created_shelter.id})

        self.trait_repo.create_default_traits(
            self.db,
            created_shelter.id,
            DEFAULT_TRAITS
        )

        return {
            "shelter": ShelterResponse.model_validate(created_shelter),
            "access_token": new_token,
            "token_type": "bearer"
        }

    def get_shelter_by_id(self, shelter_id: int) -> Optional[ShelterResponse]:
        shelter = self.shelter_repo.get_by_id(self.db, shelter_id)
        if shelter:
            return ShelterResponse.model_validate(shelter)
        else:
            raise NotFoundError("Shelter not found")

    def get_shelter_basic_info_by_id(self, shelter_id: int) -> Optional[ShelterBasicInfoResponse]:
        shelter = self.shelter_repo.get_by_id(self.db, shelter_id)
        if shelter:
            return ShelterBasicInfoResponse.model_validate(shelter)
        else:
            raise NotFoundError("Shelter not found")

    def update_shelter(self, shelter_id: int, data: ShelterUpdate) -> ShelterResponse:
        update_data = data.model_dump(exclude_unset=True)
        updated_shelter = self.shelter_repo.update(self.db, shelter_id, update_data)
        if not updated_shelter:
            raise NotFoundError("Shelter not found")
        return ShelterResponse.model_validate(updated_shelter)

    def join_as_volunteer(self, user_id: int, shelter_code: str, user_email: str) -> dict:
        shelter = self.shelter_repo.get_by_volunteer_code(self.db, shelter_code)
        if not shelter:
            raise NotFoundError("Invalid volunteer code")

        self.create_volunteer_member(user_id, shelter_code)
        acc_token = create_access_token(data={"sub": user_email, "role": RoleEnum.VOLUNTEER.value, "shelter_id": shelter.id})
        return {"access_token": acc_token, "token_type": "bearer"}

    def join_as_manager(self, user_id: int, shelter_code: str, user_email: str) -> dict:
        shelter = self.shelter_repo.get_by_manager_code(self.db, shelter_code)
        if not shelter:
            raise NotFoundError("Invalid manager code")

        self.create_manager_member_by_id(user_id, shelter.id)
        acc_token = create_access_token(data={"sub": user_email, "role": RoleEnum.MANAGER.value, "shelter_id": shelter.id})
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
            raise NotFoundError(f"Shelter with code {shelter_code} not found")
        return self.create_volunteer_member_by_id(user_id, shelter.id)

    def reset_manager_code(self, shelter_id: int) -> str:
        shelter = self.shelter_repo.get_by_id(self.db, shelter_id)
        if not shelter:
            raise NotFoundError(f"Shelter with id {shelter_id} not found")
        new_code = generate_code()
        self.shelter_repo.update_manager_code(self.db, shelter_id, new_code)
        return new_code

    def reset_volunteer_code(self, shelter_id: int) -> str:
        shelter = self.shelter_repo.get_by_id(self.db, shelter_id)
        if not shelter:
            raise NotFoundError(f"Shelter with id {shelter_id} not found")
        new_code = generate_code()
        self.shelter_repo.update_volunteer_code(self.db, shelter_id, new_code)
        return new_code