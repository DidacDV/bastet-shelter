from sqlalchemy import String
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base

from app.models.adoption.adoption_steps.magic_link_token import MagicLinkToken

class Adoptant(Base):
    __tablename__ = "adoptant"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String, nullable=False, unique=True)
    name: Mapped[str] = mapped_column(String, nullable=False)

    adoption_processes = relationship("AdoptionProcess", back_populates="adoptant", cascade="all, delete-orphan")
    magic_link_tokens = relationship("MagicLinkToken", back_populates="adoptant", cascade="all, delete-orphan")