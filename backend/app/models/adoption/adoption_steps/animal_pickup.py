from datetime import datetime

from sqlalchemy import DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.adoption.adoption_steps.adoption_step import AdoptionStep, StepTypeEnum


class AnimalPickup(AdoptionStep):
    __tablename__ = "animal_pickup"

    __mapper_args__ = {
        "polymorphic_identity": StepTypeEnum.ANIMAL_PICKUP,
    }

    id: Mapped[int] = mapped_column(ForeignKey("adoption_step.id", ondelete="CASCADE"), primary_key=True)
    scheduled_at: Mapped[datetime] = mapped_column(DateTime, nullable=True)
    actual_pickup_at: Mapped[datetime] = mapped_column(DateTime, nullable=True)