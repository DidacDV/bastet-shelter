import enum
from datetime import datetime
from sqlalchemy import Integer, String, ForeignKey, Boolean, DateTime, Enum, Text
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.sql import func
from app.database import Base

class AdCategoryEnum(str, enum.Enum):
    FOOD = "FOOD"
    MEDICINE = "MEDICINE"
    EQUIPMENT = "EQUIPMENT"
    TOYS = "TOYS"
    OTHER = "OTHER"

class Advertisement(Base):
    __tablename__ = "advertisement"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    category: Mapped[AdCategoryEnum] = mapped_column(Enum(AdCategoryEnum), default=AdCategoryEnum.OTHER, nullable=False)
    published_on: Mapped[datetime] = mapped_column(DateTime, default=func.now(), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    image_url: Mapped[str | None] = mapped_column(String, nullable=True)
    image_public_id: Mapped[str | None] = mapped_column(String, nullable=True)
    province_id: Mapped[str] = mapped_column(ForeignKey("provinces.id"), nullable=False)
    shelter_id: Mapped[int] = mapped_column(ForeignKey("shelter.id"), nullable=False)

    province = relationship("Province")
    shelter = relationship("Shelter", back_populates="advertisements")

    @property
    def province_name(self) -> str:
        return self.province.name if self.province else ""

    @property
    def shelter_name(self) -> str:
        return self.shelter.name if self.shelter else ""

    @property
    def shelter_email(self) -> str:
        return self.shelter.email if self.shelter else ""
