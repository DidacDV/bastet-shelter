import enum

from sqlalchemy import String, Integer, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base

class Medicine(Base):
    __tablename__ = "medicine"
    __table_args__ = (UniqueConstraint("name", "shelter_id", name="uq_medicine_name_shelter"),)

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    current_stock: Mapped[int] = mapped_column(Integer, nullable=False)
    shelter_id: Mapped[int] = mapped_column(ForeignKey("shelter.id", ondelete="CASCADE"), nullable=False)

    shelter = relationship("Shelter", back_populates="medicines")
    treatments = relationship("AnimalTreatment", back_populates="medicine")