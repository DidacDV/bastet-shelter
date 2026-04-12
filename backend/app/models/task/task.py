import enum
from datetime import date, datetime
from typing import Optional

from sqlalchemy import String, Date, DateTime, ForeignKey, Enum, Integer
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base


class TaskStatusEnum(str, enum.Enum):
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"
    NOT_COMPLETED = "NOT_COMPLETED"


class Task(Base):
    __tablename__ = "task"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    num_people: Mapped[int] = mapped_column(Integer, nullable=False)
    shelter_id: Mapped[int] = mapped_column(ForeignKey("shelter.id"), nullable=False)

    shelter = relationship("Shelter")
    shift_tasks = relationship("ShiftTask", back_populates="task")