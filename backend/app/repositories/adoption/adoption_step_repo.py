from sqlalchemy.orm import Session

from app.models.adoption.adoption_steps.adoption_step import AdoptionStep, StepStatusEnum
from app.repositories.generic_repo import BaseRepository


class AdoptionStepRepository(BaseRepository[AdoptionStep]):
    def __init__(self, db: Session):
        super().__init__(AdoptionStep)
        self.db = db

    def get_current_step(self, db: Session, process_id: int) -> type[AdoptionStep] | None:
        """Returns the lowest-order step that is still PENDING."""
        return (
            db.query(AdoptionStep)
            .filter(
                AdoptionStep.adoption_process_id == process_id,
                AdoptionStep.status == StepStatusEnum.PENDING
            )
            .order_by(AdoptionStep.order)
            .first()
        )

    def get_step_by_id(self, db: Session, step_id: int) -> type[AdoptionStep] | None:
        return db.query(AdoptionStep).filter(AdoptionStep.id == step_id).first()

    def get_steps_for_process(self, db: Session, process_id: int) -> list[type[AdoptionStep]]:
        return (
            db.query(AdoptionStep)
            .filter(AdoptionStep.adoption_process_id == process_id)
            .order_by(AdoptionStep.order)
            .all()
        )

    def mark_all_rejected(self, db: Session, process_id: int) -> None:
        db.query(AdoptionStep).filter(
            AdoptionStep.adoption_process_id == process_id,
            AdoptionStep.status == StepStatusEnum.PENDING
        ).update({"status": StepStatusEnum.REJECTED})
        db.commit()

    def save(self, db: Session, step: AdoptionStep) -> AdoptionStep:
        db.add(step)
        db.commit()
        db.refresh(step)
        return step