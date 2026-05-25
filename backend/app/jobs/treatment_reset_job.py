from datetime import datetime, timezone
from sqlalchemy.orm import Session
from app.models.medical.medical_treatment import AnimalTreatment, MedicineStatusEnum, MedicineFrequencyEnum
from app.database import SessionLocal

FREQUENCY_DAYS = {
    MedicineFrequencyEnum.DAILY: 1,
    MedicineFrequencyEnum.WEEKLY: 7,
    MedicineFrequencyEnum.MONTHLY: 30,
}

def reset_treatments():
    db: Session = SessionLocal()
    try:
        now = datetime.now(timezone.utc)

        treatments = db.query(AnimalTreatment).filter(
            AnimalTreatment.status == MedicineStatusEnum.GIVEN,
        ).all()

        for treatment in treatments:
            frequency_days = FREQUENCY_DAYS.get(treatment.frequency)
            if frequency_days is None:
                continue

            last_updated = treatment.status_updated_at
            if last_updated is None:
                continue

            if last_updated.tzinfo is None:
                last_updated = last_updated.replace(tzinfo=timezone.utc)

            if (now - last_updated).days >= frequency_days:
                treatment.status = MedicineStatusEnum.PENDING
                treatment.status_last_updated_by_id = None

        db.commit()
    except Exception as e:
        db.rollback()
        raise e
    finally:
        db.close()