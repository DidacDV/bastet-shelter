import enum
from datetime import date, datetime
from typing import Optional

from sqlalchemy import String, Date, DateTime, ForeignKey, Enum, Integer
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base

class ShiftParticipant(Base):
    """links a member to a shift"""
    __tablename__ = "shift_participant"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    shift_id: Mapped[int] = mapped_column(ForeignKey("shift.id"), nullable=False)
    member_id: Mapped[Optional[int]] = mapped_column(ForeignKey("shelter_member.id"), nullable=True)

    shift = relationship("Shift", back_populates="participants")
    member = relationship("ShelterMember")
    shift_tasks = relationship("ShiftTask", back_populates="participant")

    @property
    def name(self) -> str | None:
        if self.member and self.member.user:
            return self.member.user.name
        return None

    @property
    def last_name_1(self) -> str | None:
        if self.member and self.member.user:
            return self.member.user.last_name_1
        return None