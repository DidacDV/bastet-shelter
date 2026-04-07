import enum
from datetime import datetime, date

from sqlalchemy import DateTime, ForeignKey, Enum, Date
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base

from app.models.medical.medicine import Medicine

class MedicineFrequencyEnum(str, enum.Enum):
    DAILY = "DAILY"
    WEEKLY = "WEEKLY"
    MONTHLY = "MONTHLY"
    AS_NEEDED = "AS_NEEDED"


class MedicineStatusEnum(str, enum.Enum):
    GIVEN = "GIVEN"
    PENDING = "PENDING"

class AnimalTreatment(Base):
    __tablename__ = "animal_treatment"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    animal_id: Mapped[int] = mapped_column(ForeignKey("animal.id", ondelete="CASCADE"), nullable=False)
    medicine_id: Mapped[int] = mapped_column(ForeignKey("medicine.id", ondelete="CASCADE"), nullable=False)

    frequency: Mapped[MedicineFrequencyEnum] = mapped_column(Enum(MedicineFrequencyEnum), nullable=False)
    status: Mapped[MedicineStatusEnum] = mapped_column(Enum(MedicineStatusEnum), nullable=False, default=MedicineStatusEnum.PENDING)
    status_updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[date] = mapped_column(Date, nullable=True)  # None = ongoing

    animal = relationship("Animal", back_populates="treatments")
    medicine = relationship("Medicine", back_populates="treatments")