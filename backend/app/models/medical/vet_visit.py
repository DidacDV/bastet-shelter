import enum
from datetime import date

from sqlalchemy import String, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base

class VetVisitTypeEnum(str, enum.Enum):
    GENERAL_CHECKUP = "GENERAL_CHECKUP"
    VACCINE = "VACCINE"
    SURGERY = "SURGERY"
    DENTAL = "DENTAL"
    EMERGENCY = "EMERGENCY"
    OTHER = "OTHER"


class VetVisit(Base):
    __tablename__ = "vet_visit"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    animal_id: Mapped[int] = mapped_column(ForeignKey("animal.id", ondelete="CASCADE"), nullable=False)

    visit_date: Mapped[date] = mapped_column(DateTime(timezone=True), nullable=False)
    visit_type: Mapped[VetVisitTypeEnum] = mapped_column(Enum(VetVisitTypeEnum), nullable=False)
    clinic_name: Mapped[str] = mapped_column(String, nullable=False)
    notes: Mapped[str] = mapped_column(String, nullable=True)

    animal = relationship("Animal", back_populates="vet_visits")