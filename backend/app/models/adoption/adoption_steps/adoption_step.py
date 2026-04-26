import enum
from datetime import date

from sqlalchemy import Date, Enum, ForeignKey, Integer, String
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base


class StepTypeEnum(str, enum.Enum):
    FORM = "FORM"
    INTERVIEW = "INTERVIEW"
    SHELTER_VISIT = "SHELTER_VISIT"
    CONTRACT = "CONTRACT"
    ANIMAL_PICKUP = "ANIMAL_PICKUP"


class StepStatusEnum(str, enum.Enum):
    PENDING = "PENDING"
    COMPLETED = "COMPLETED"
    REJECTED = "REJECTED"
    SKIPPED = "SKIPPED"

STEP_ORDER: list[StepTypeEnum] = [
    StepTypeEnum.FORM,
    StepTypeEnum.INTERVIEW,
    StepTypeEnum.SHELTER_VISIT,
    StepTypeEnum.CONTRACT,
    StepTypeEnum.ANIMAL_PICKUP,
]


class AdoptionStep(Base):
    __tablename__ = "adoption_step"

    __mapper_args__ = {
        "polymorphic_on": "type",
        "polymorphic_identity": None,
    }

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    adoption_process_id: Mapped[int] = mapped_column(
        ForeignKey("adoption_process.id", ondelete="CASCADE"), nullable=False
    )
    type: Mapped[StepTypeEnum] = mapped_column(Enum(StepTypeEnum), nullable=False)
    status: Mapped[StepStatusEnum] = mapped_column(
        Enum(StepStatusEnum), nullable=False, default=StepStatusEnum.PENDING
    )
    order: Mapped[int] = mapped_column(Integer, nullable=False)
    finish_date: Mapped[date] = mapped_column(Date, nullable=True)
    notes: Mapped[str | None] = mapped_column(String, nullable=True)
    rejection_reason: Mapped[str | None] = mapped_column(String, nullable=True)

    adoption_process = relationship("AdoptionProcess", back_populates="steps")