from sqlalchemy import String, ForeignKey
from sqlalchemy.orm import relationship, Mapped, mapped_column
from app.database import Base

DEFAULT_TRAITS = ["Friendly", "Playful", "Shy", "Calm", "Energetic"]

class Trait(Base):
    __tablename__ = "trait"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)

    shelter_id: Mapped[int] = mapped_column(ForeignKey("shelter.id", ondelete="CASCADE"), nullable=False)

    shelter = relationship("Shelter", back_populates="traits")