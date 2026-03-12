from sqlalchemy.orm import Session
from typing import Optional

from app.models.shelter import Shelter
from app.models.shelter_member import ShelterMember, RoleEnum

class ShelterMemberRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_member(self, user_id: int, shelter_id: int, role: RoleEnum) -> ShelterMember:
        """Create a new shelter member"""
        member = ShelterMember(
            user_id=user_id,
            shelter_id=shelter_id,
            role=role
        )
        self.db.add(member)
        self.db.commit()
        self.db.refresh(member)
        return member

    def get_by_user(self, user_id: int) -> Optional[ShelterMember]:
        """Get shelter member by user ID"""
        return self.db.query(ShelterMember).join(Shelter).filter(ShelterMember.user_id == user_id).first()
