import enum
from datetime import date, datetime
from typing import Optional

from sqlalchemy import String, Date, DateTime, ForeignKey, Enum, Integer
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base
from app.models.task.task import TaskStatusEnum


class ShiftTask(Base):
    """Links a task to a shift, tracking its status, who is assigned to and which animal if it's the case."""
    __tablename__ = "shift_task"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    status: Mapped[TaskStatusEnum] = mapped_column(Enum(TaskStatusEnum), nullable=False, default=TaskStatusEnum.NOT_COMPLETED)
    assigned_date: Mapped[date] = mapped_column(Date, nullable=False)
    shift_id: Mapped[int] = mapped_column(ForeignKey("shift.id"), nullable=False)
    task_id: Mapped[int] = mapped_column(ForeignKey("task.id"), nullable=False)
    participant_id: Mapped[Optional[int]] = mapped_column(ForeignKey("shift_participant.id"), nullable=True)
    animal_id: Mapped[Optional[int]] = mapped_column(ForeignKey("animal.id"), nullable=True)

    shift = relationship("Shift", back_populates="shift_tasks")
    task = relationship("Task", back_populates="shift_tasks")
    participant = relationship("ShiftParticipant", back_populates="shift_tasks")
    animal = relationship("Animal", back_populates="shift_tasks")