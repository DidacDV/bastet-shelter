import enum
from datetime import date

from sqlalchemy import String, Boolean, Date, ForeignKey, Enum, Table, Column
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base
from app.models import trait
from app.models.medical.medical_treatment import AnimalTreatment
from app.models.medical.vet_visit import VetVisit
from app.models.animal.animal_image import AnimalImage
from app.models.adoption.adoption_process import AdoptionProcess
from app.models.task.shift_task import ShiftTask
from app.models.refuge import Refuge
from app.models.shelter_member import ShelterMember

class AnimalTypeEnum(str, enum.Enum):
    CAT = "CAT"
    DOG = "DOG"
    OTHER= "OTHER"

animal_trait_association = Table(
    "animal_trait",
    Base.metadata,
    Column("animal_id", ForeignKey("animal.id", ondelete="CASCADE"), primary_key=True),
    Column("trait_id", ForeignKey(trait.Trait.id, ondelete="CASCADE"), primary_key=True),
)

class Animal(Base):
    __tablename__ = "animal"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    birth_date: Mapped[date] = mapped_column(Date, nullable=False)
    arrival_date: Mapped[date] = mapped_column(Date, nullable=True)
    description: Mapped[str] = mapped_column(String, nullable=False)
    breed: Mapped[str] = mapped_column(String, nullable=False)
    animal_type: Mapped[AnimalTypeEnum] = mapped_column(Enum(AnimalTypeEnum), nullable=False)
    in_adoption: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    refuge_id: Mapped[int] = mapped_column(ForeignKey("refuge.id"), nullable=False)

    refuge = relationship("Refuge", back_populates="animals")
    shift_tasks = relationship("ShiftTask", back_populates="animal")
    traits = relationship("Trait", secondary=animal_trait_association, backref="animals")
    treatments = relationship("AnimalTreatment", back_populates="animal", cascade="all, delete-orphan")
    vet_visits = relationship("VetVisit", back_populates="animal", cascade="all, delete-orphan")
    images = relationship("AnimalImage", back_populates="animal", cascade="all, delete-orphan")
    adoption_processes = relationship("AdoptionProcess", back_populates="animal", cascade="all, delete-orphan")

    @property
    def age(self) -> int:
        if not self.birth_date:
            return 0
        today = date.today()
        return today.year - self.birth_date.year - (
                (today.month, today.day) < (self.birth_date.month, self.birth_date.day)
        )

    @property
    def pending_shift_tasks(self) -> int:
        if not self.shift_tasks:
            return 0
        return sum(1 for t in self.shift_tasks if t.status.name == "NOT_COMPLETED")

    @property
    def refuge_name(self) -> str | None:
        return self.refuge.name if self.refuge else None

    @property
    def image_url(self) -> str | None:
        if self.images:
            return self.images[0].url
        return None