import enum
from datetime import date

from sqlalchemy import String, Boolean, Date, ForeignKey, Enum
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base


class AnimalTypeEnum(str, enum.Enum):
    CAT = "CAT"
    DOG = "DOG"


class Animal(Base):
    __tablename__ = "animal"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    birth_date: Mapped[date] = mapped_column(Date, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    breed: Mapped[str] = mapped_column(String, nullable=False)
    animal_type: Mapped[AnimalTypeEnum] = mapped_column(Enum(AnimalTypeEnum), nullable=False)
    in_adoption: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    refuge_id: Mapped[int] = mapped_column(ForeignKey("refuge.id"), nullable=False)

    refuge = relationship("Refuge", back_populates="animals")
    shift_tasks = relationship("ShiftTask", back_populates="animal")