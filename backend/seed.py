import asyncio
from sqlite3 import Date

from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.database import SessionLocal, engine, Base
from app.models.login import Login
from app.models.refuge import Refuge
from app.models.shelter_member import ShelterMember
from app.models.user import User
from app.models.shelter import Shelter
from app.models.animal import Animal, AnimalTypeEnum
from app.models.shift.shift import Shift
from app.models.shift.shift_participant import ShiftParticipant
from app.models.task.task import Task
from app.models.task.shift_task import ShiftTask
from app.models.province import Province
from app.models.trait import Trait
from app.models.medical.vet_visit import VetVisit
from app.models.medical.medical_treatment import AnimalTreatment
from app.models.medical.medicine import Medicine

from app.services.geo_service import GeoService


import app.models as models

async def seed_data():
    db = SessionLocal()
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    try:
        await GeoService.run_periodic_update(db)
        db.commit()

        login_val = Login(id=1, email="d@gmail.com", password=hash_password("d"))
        db.add(login_val)
        manager = User(
            id=1,
            name="Didac",
            last_name_1="Dalmases",
            active=True,
            login_id=login_val.id
        )
        db.add(manager)
        db.flush()

        shelter = Shelter(name="Bastet's Hope",province_id="08", volunteer_code="VOL123", manager_code="MAN456")
        db.add(shelter)
        db.flush()

        member = ShelterMember(user_id=manager.id, shelter_id=shelter.id, role="MANAGER")
        db.add(member)

        meds = [
            Medicine(name="Amoxicillin", current_stock=50, shelter_id=shelter.id),
            Medicine(name="Metacam", current_stock=20, shelter_id=shelter.id),
        ]
        db.add_all(meds)

        rfg = Refuge(name="RubiRfg", province_id="08", shelter_id=shelter.id)
        db.add(rfg)
        db.flush()

        buddy = Animal(
            name="Buddy",
            birth_date=Date(2026, 0o4, 0o1),
            animal_type=AnimalTypeEnum.DOG,
            breed="Golden Retriever",
            description="Very friendly",
            refuge_id=rfg.id,
            in_adoption=True
        )
        db.add(buddy)

        db.commit()
        print("login with: d@gmail.com / d")
    except Exception as e:
        print(f"Error seeding: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    asyncio.run(seed_data())