from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, String
from sqlalchemy.orm import relationship, Mapped, mapped_column

from app.database import Base


class MagicLinkToken(Base):
    __tablename__ = "magic_link_token"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    adoptant_id: Mapped[int] = mapped_column(ForeignKey("adoptant.id", ondelete="CASCADE"), nullable=False)
    token: Mapped[str] = mapped_column(String, nullable=False, unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)

    adoptant = relationship("Adoptant", back_populates="magic_link_tokens")