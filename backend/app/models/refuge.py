from sqlalchemy import String, ForeignKey
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base


class Refuge(Base):
    __tablename__ = "refuge"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    province_id: Mapped[str] = mapped_column(ForeignKey("provinces.id"), nullable=False)
    shelter_id: Mapped[int] = mapped_column(ForeignKey("shelter.id"), nullable=False)

    province = relationship("Province")
    shelter = relationship("Shelter", back_populates="refuges")
    animals = relationship("Animal", back_populates="refuge")
    shifts = relationship("Shift", back_populates="refuge")