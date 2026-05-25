from datetime import date, timedelta

from app.models.animal.animal import Animal, AnimalTypeEnum
from app.models.medical.medical_treatment import AnimalTreatment, DosageUnitEnum, MedicineFrequencyEnum
from app.models.medical.medicine import Medicine
from app.models.refuge import Refuge
from app.repositories.medicine_repo import MedicineRepository
from tests.repositories.utils import _create_shelter


class TestMedicineRepository:
    repo = MedicineRepository(None)

    def test_is_used_in_active_treatment(self, db):
        shelter = _create_shelter(db)
        refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
        active_medicine = Medicine(name="Amoxicillin", current_stock=10, shelter_id=shelter.id)
        finished_medicine = Medicine(name="Doxycycline", current_stock=8, shelter_id=shelter.id)
        unused_medicine = Medicine(name="Meloxicam", current_stock=5, shelter_id=shelter.id)
        db.add_all([refuge, active_medicine, finished_medicine, unused_medicine])
        db.commit()
        db.refresh(refuge)
        db.refresh(active_medicine)
        db.refresh(finished_medicine)
        db.refresh(unused_medicine)

        animal = Animal(
            name="Milo",
            birth_date=date(2026, 1, 1),
            description="Desc",
            breed="Mixed",
            animal_type=AnimalTypeEnum.CAT,
            refuge_id=refuge.id,
        )
        db.add(animal)
        db.commit()
        db.refresh(animal)

        active_treatment = AnimalTreatment(
            animal_id=animal.id,
            medicine_id=active_medicine.id,
            frequency=MedicineFrequencyEnum.DAILY,
            start_date=date(2026, 1, 1),
            dosage=1.0,
            dosage_unit=DosageUnitEnum.MG,
        )
        finished_treatment = AnimalTreatment(
            animal_id=animal.id,
            medicine_id=finished_medicine.id,
            frequency=MedicineFrequencyEnum.DAILY,
            start_date=date.today() - timedelta(days=5),
            end_date=date.today() - timedelta(days=1),
            dosage=1.0,
            dosage_unit=DosageUnitEnum.MG,
        )
        db.add_all([active_treatment, finished_treatment])
        db.commit()

        assert self.repo.is_used_in_active_treatment(db, active_medicine.id) is True
        assert self.repo.is_used_in_active_treatment(db, finished_medicine.id) is False
        assert self.repo.is_used_in_active_treatment(db, unused_medicine.id) is False
