from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import mapped_column, Mapped, relationship

from app.database import Base


class AnimalImage(Base):
    __tablename__ = "animal_image"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    animal_id: Mapped[int] = mapped_column(ForeignKey("animal.id", ondelete="CASCADE"), nullable=False)
    url: Mapped[str] = mapped_column(String, nullable=False)
    cloudinary_public_id: Mapped[str] = mapped_column(String, nullable=False)
    order: Mapped[int] = mapped_column(default=0)

    animal = relationship("Animal", back_populates="images")