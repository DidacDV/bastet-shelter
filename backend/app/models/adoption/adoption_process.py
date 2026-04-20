import enum
from datetime import date

from sqlalchemy import Date, Enum, ForeignKey
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base
from app.models.adoption.adoptant import Adoptant
from app.models.adoption.adoption_steps.adoption_step import AdoptionStep

class AdoptionProcessStatusEnum(str, enum.Enum):
    ACTIVE = "ACTIVE"
    COMPLETED = "COMPLETED"
    REJECTED = "REJECTED"


class AdoptionProcess(Base):
    __tablename__ = "adoption_process"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    animal_id: Mapped[int] = mapped_column(ForeignKey("animal.id", ondelete="CASCADE"), nullable=False)
    adoptant_id: Mapped[int] = mapped_column(ForeignKey("adoptant.id", ondelete="CASCADE"), nullable=False)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[date] = mapped_column(Date, nullable=True)
    status: Mapped[AdoptionProcessStatusEnum] = mapped_column(
        Enum(AdoptionProcessStatusEnum),
        nullable=False,
        default=AdoptionProcessStatusEnum.ACTIVE
    )

    animal = relationship("Animal", back_populates="adoption_processes")
    adoptant = relationship("Adoptant", back_populates="adoption_processes")
    steps = relationship("AdoptionStep", back_populates="adoption_process", cascade="all, delete-orphan")