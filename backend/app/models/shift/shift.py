import enum
from datetime import date, datetime
from typing import Optional

from sqlalchemy import String, Date, DateTime, ForeignKey, Enum, Integer
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base

class Shift(Base):
    __tablename__ = "shift"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    start_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    end_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    day: Mapped[date] = mapped_column(Date, nullable=False)
    shelter_id: Mapped[int] = mapped_column(ForeignKey("shelter.id"), nullable=False)
    refuge_id: Mapped[int] = mapped_column(ForeignKey("refuge.id"), nullable=False)
    max_participants: Mapped[int] = mapped_column(Integer, nullable=True)

    refuge = relationship("Refuge", back_populates="shifts")
    participants = relationship("ShiftParticipant", back_populates="shift", cascade="all, delete-orphan")
    shift_tasks = relationship("ShiftTask", back_populates="shift", cascade="all, delete-orphan")

    @property
    def current_participants(self) -> int:
        return len(self.participants)