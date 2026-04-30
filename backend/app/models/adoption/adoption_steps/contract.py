from datetime import date

from sqlalchemy import Boolean, Date, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.adoption.adoption_steps.adoption_step import AdoptionStep, StepTypeEnum


class Contract(AdoptionStep):
    __tablename__ = "contract"

    __mapper_args__ = {
        "polymorphic_identity": StepTypeEnum.CONTRACT,
    }

    id: Mapped[int] = mapped_column(ForeignKey("adoption_step.id", ondelete="CASCADE"), primary_key=True)
    contract_url: Mapped[str] = mapped_column(String, nullable=True)
    cloudinary_public_id: Mapped[str] = mapped_column(String, nullable=True)
    generation_date: Mapped[date] = mapped_column(Date, nullable=True)
    signed_by_adoptant: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    signed_by_shelter: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)