from sqlalchemy import Boolean, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.adoption.adoption_steps.adoption_step import AdoptionStep, StepTypeEnum


class AdoptionForm(AdoptionStep):
    __tablename__ = "adoption_form"

    __mapper_args__ = {
        "polymorphic_identity": StepTypeEnum.FORM,
    }

    id: Mapped[int] = mapped_column(ForeignKey("adoption_step.id", ondelete="CASCADE"), primary_key=True)

    housing_type: Mapped[str] = mapped_column(String, nullable=True)
    has_garden: Mapped[bool] = mapped_column(Boolean, nullable=True)
    has_other_pets: Mapped[bool] = mapped_column(Boolean, nullable=True)
    other_pets_description: Mapped[str] = mapped_column(String, nullable=True)
    has_children: Mapped[bool] = mapped_column(Boolean, nullable=True)
    children_ages: Mapped[str] = mapped_column(String, nullable=True)

    previous_pet_experience: Mapped[bool] = mapped_column(Boolean, nullable=True)
    hours_alone_per_day: Mapped[int] = mapped_column(Integer, nullable=True)
    reason_for_adoption: Mapped[str] = mapped_column(Text, nullable=True)

    accepted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)