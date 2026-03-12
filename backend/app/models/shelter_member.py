import enum
from datetime import date

from sqlalchemy import Column, Integer, ForeignKey, Enum, Date, UniqueConstraint
from sqlalchemy.orm import relationship

from app.database import Base

class RoleEnum(str, enum.Enum):
    VOLUNTEER = "VOLUNTEER"
    MANAGER = "MANAGER"
    ADMIN = "ADMIN"

class ShelterMember(Base):
    __tablename__ = "shelter_member"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    shelter_id = Column(Integer, ForeignKey("shelter.id"), nullable=False)
    role = Column(Enum(RoleEnum), nullable=False)
    join_date = Column(Date, nullable=False, default=date.today)

    user = relationship("User")
    shelter = relationship("Shelter")

    __table_args__ = (
        UniqueConstraint('user_id', name='uq_shelter_member_user_id'),
    )
