from typing import Optional

from app.repositories.generic_repo import BaseRepository
from sqlalchemy.orm import Session

from app.models.shelter import Shelter
from app.models.shelter_member import ShelterMember, RoleEnum, Volunteer


class ShelterMemberRepository(BaseRepository[ShelterMember]):
    def __init__(self, db: Session):
        super().__init__(ShelterMember)
        self.db = db

    def create_member(self, user_id: int, shelter_id: int, role: RoleEnum) -> ShelterMember:
        member = ShelterMember(user_id=user_id, shelter_id=shelter_id, role=role)
        return self.create(self.db, member)

    def get_by_user(self, user_id: int) -> Optional[ShelterMember]:
        return self.db.query(ShelterMember).join(Shelter).filter(ShelterMember.user_id == user_id).first()

    def count_volunteers(self, db, shelter_id):
        return (db.query(Volunteer).filter(ShelterMember.shelter_id == shelter_id, ShelterMember.role == RoleEnum.VOLUNTEER)
            .count())