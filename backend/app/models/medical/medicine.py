import enum

from sqlalchemy import String, Integer
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base



class DosageUnitEnum(str, enum.Enum):
    MG = "MG"
    ML = "ML"
    DROPS = "DROPS"
    UNITS = "UNITS"

class Medicine(Base):
    __tablename__ = "medicine"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False, unique=True)
    current_stock: Mapped[int] = mapped_column(Integer, nullable=False)


    treatments = relationship("AnimalTreatment", back_populates="medicine")