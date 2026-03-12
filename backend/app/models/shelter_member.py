import enum
from datetime import date
from typing import Optional

from sqlalchemy import Enum, UniqueConstraint, ForeignKey
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base


class RoleEnum(str, enum.Enum):
    VOLUNTEER = "VOLUNTEER"
    MANAGER = "MANAGER"
    ADMIN = "ADMIN"


class ShelterMember(Base):
    __tablename__ = "shelter_member"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("user.id"), nullable=False)
    shelter_id: Mapped[int] = mapped_column(ForeignKey("shelter.id"), nullable=False)
    role: Mapped[RoleEnum] = mapped_column(Enum(RoleEnum), nullable=False)
    join_date: Mapped[date] = mapped_column(nullable=False, default=date.today)
    type: Mapped[str]

    user = relationship("User")
    shelter = relationship("Shelter")

    __mapper_args__ = {
        "polymorphic_on": "type",
        "polymorphic_identity": "member"
    }

    __table_args__ = (
        UniqueConstraint('user_id', name='uq_shelter_member_user_id'),
    )


class Volunteer(ShelterMember):
    __tablename__ = "volunteer"

    id: Mapped[int] = mapped_column(ForeignKey("shelter_member.id"), primary_key=True)
    hours_worked: Mapped[Optional[int]] = mapped_column(nullable=True)

    __mapper_args__ = {"polymorphic_identity": "volunteer"}


class Manager(ShelterMember):
    __tablename__ = "manager"

    id: Mapped[int] = mapped_column(ForeignKey("shelter_member.id"), primary_key=True)

    __mapper_args__ = {"polymorphic_identity": "manager"}