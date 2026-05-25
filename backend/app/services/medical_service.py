from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError, AuthorizationError, BusinessLogicError
from app.models.medical.medical_treatment import AnimalTreatment
from app.models.medical.medicine import Medicine
from app.models.medical.vet_visit import VetVisit
from app.repositories.animal_repo import AnimalRepository
from app.repositories.medical_treatment_repo import MedicalTreatmentRepository
from app.repositories.medicine_repo import MedicineRepository
from app.repositories.refuge_repo import RefugeRepository
from app.repositories.vet_visit_repo import VetVisitRepository
from app.schemas.medical_schema import (
    MedicineCreate, MedicineResponse, MedicineUpdate,
    MedicalTreatmentCreate, MedicalTreatmentResponse, MedicalTreatmentUpdate,
    VetVisitCreate, VetVisitResponse, VetVisitUpdate,
)


class MedicalService:
    def __init__(self, db: Session):
        self.db = db
        self.medicine_repo = MedicineRepository(db)
        self.treatment_repo = MedicalTreatmentRepository(db)
        self.vet_visit_repo = VetVisitRepository(db)
        self.animal_repo = AnimalRepository(db)
        self.refuge_repo = RefugeRepository(db)

    def _medicine_to_response(self, medicine: Medicine) -> MedicineResponse:
        return MedicineResponse(
            id=medicine.id,
            name=medicine.name,
            current_stock=medicine.current_stock,
        )

    def _treatment_to_response(self, treatment: AnimalTreatment) -> MedicalTreatmentResponse:
        return MedicalTreatmentResponse(
            id=treatment.id,
            animal_id=treatment.animal_id,
            medicine_id=treatment.medicine_id,
            medicine_name=treatment.medicine.name,
            frequency=treatment.frequency,
            status=treatment.status,
            status_updated_at=treatment.status_updated_at,
            start_date=treatment.start_date,
            end_date=treatment.end_date,
            dosage=treatment.dosage,
            dosage_unit=treatment.dosage_unit,
            status_last_updated_by_name=treatment.status_last_updated_by_name,
        )

    def _vet_visit_to_response(self, visit: VetVisit) -> VetVisitResponse:
        return VetVisitResponse(
            id=visit.id,
            animal_id=visit.animal_id,
            visit_date=visit.visit_date,
            visit_type=visit.visit_type,
            clinic_name=visit.clinic_name,
            notes=visit.notes,
        )

    def _validate_animal_belongs_to_shelter(self, animal_id: int, shelter_id: int) -> None:
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise NotFoundError("Animal not found")
        refuge = self.refuge_repo.get_by_id(self.db, animal.refuge_id)
        if not refuge or refuge.shelter_id != shelter_id:
            raise AuthorizationError("Not authorized to manage this animal's medical records")

    def _validate_medicine_belongs_to_shelter(self, medicine: Medicine, shelter_id: int) -> None:
        if medicine.shelter_id != shelter_id:
            raise AuthorizationError("Not authorized to manage this medicine")

    # MEDICINE
    def create_medicine(self, data: MedicineCreate, shelter_id: int) -> MedicineResponse:
        existing = self.medicine_repo.get_by_name_and_shelter(self.db, data.name, shelter_id)
        if existing:
            raise BusinessLogicError("A medicine with this name already exists")
        medicine = Medicine(**data.model_dump(), shelter_id=shelter_id)
        created = self.medicine_repo.create(self.db, medicine)
        return self._medicine_to_response(created)

    def get_all_medicines(self, shelter_id: int) -> list[MedicineResponse]:
        medicines = self.medicine_repo.get_by_shelter(self.db, shelter_id)
        return [self._medicine_to_response(m) for m in medicines]

    def get_medicine_by_id(self, medicine_id: int, shelter_id: int) -> MedicineResponse:
        medicine = self.medicine_repo.get_by_id(self.db, medicine_id)
        if not medicine:
            raise NotFoundError("Medicine not found")
        self._validate_medicine_belongs_to_shelter(medicine, shelter_id)
        return self._medicine_to_response(medicine)

    def update_medicine(self, medicine_id: int, data: MedicineUpdate, shelter_id: int) -> MedicineResponse:
        medicine = self.medicine_repo.get_by_id(self.db, medicine_id)
        if not medicine:
            raise NotFoundError("Medicine not found")
        self._validate_medicine_belongs_to_shelter(medicine, shelter_id)

        update_data = data.model_dump(exclude_unset=True)

        if "name" in update_data and update_data["name"] != medicine.name:
            existing = self.medicine_repo.get_by_name_and_shelter(self.db, update_data["name"], shelter_id)
            if existing:
                raise BusinessLogicError("A medicine with this name already exists")

        updated = self.medicine_repo.update(self.db, medicine_id, update_data)
        return self._medicine_to_response(updated)

    def delete_medicine(self, medicine_id: int, shelter_id: int) -> None:
        medicine = self.medicine_repo.get_by_id(self.db, medicine_id)
        if not medicine:
            raise NotFoundError("Medicine not found")
        self._validate_medicine_belongs_to_shelter(medicine, shelter_id)
        if self.medicine_repo.is_used_in_active_treatment(self.db, medicine_id):
            raise BusinessLogicError("Medicine is used in an active treatment and cannot be deleted")
        self.medicine_repo.delete(self.db, medicine_id)

    # TREATMENT
    def create_treatment(self, data: MedicalTreatmentCreate, shelter_id: int) -> MedicalTreatmentResponse:
        self._validate_animal_belongs_to_shelter(data.animal_id, shelter_id)

        medicine = self.medicine_repo.get_by_id(self.db, data.medicine_id)
        if not medicine:
            raise NotFoundError("Medicine not found")

        treatment = AnimalTreatment(**data.model_dump())
        created = self.treatment_repo.create(self.db, treatment)
        return self._treatment_to_response(created)

    def get_treatments_by_animal(self, animal_id: int) -> list[MedicalTreatmentResponse]:
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise NotFoundError("Animal not found")
        treatments = self.treatment_repo.get_by_animal(self.db, animal_id)
        return [self._treatment_to_response(t) for t in treatments]

    def update_treatment(self, user_id: int, treatment_id: int, data: MedicalTreatmentUpdate, shelter_id: int) -> MedicalTreatmentResponse:
        treatment = self.treatment_repo.get_by_id(self.db, treatment_id)
        if not treatment:
            raise NotFoundError("Treatment not found")

        self._validate_animal_belongs_to_shelter(treatment.animal_id, shelter_id)

        update_data = data.model_dump(exclude_unset=True)

        if "status" in update_data and update_data["status"] != treatment.status:
            treatment.status_last_updated_by_id = user_id

        if "medicine_id" in update_data:
            medicine = self.medicine_repo.get_by_id(self.db, update_data["medicine_id"])
            if not medicine:
                raise NotFoundError("Medicine not found")

        updated = self.treatment_repo.update(self.db, treatment_id, update_data)
        return self._treatment_to_response(updated)

    def delete_treatment(self, treatment_id: int, shelter_id: int) -> None:
        treatment = self.treatment_repo.get_by_id(self.db, treatment_id)
        if not treatment:
            raise NotFoundError("Treatment not found")
        self._validate_animal_belongs_to_shelter(treatment.animal_id, shelter_id)
        self.treatment_repo.delete(self.db, treatment_id)

    # VET VISITS
    def create_vet_visit(self, data: VetVisitCreate, shelter_id: int) -> VetVisitResponse:
        self._validate_animal_belongs_to_shelter(data.animal_id, shelter_id)
        visit = VetVisit(**data.model_dump())
        created = self.vet_visit_repo.create(self.db, visit)
        return self._vet_visit_to_response(created)

    def get_vet_visits_by_animal(self, animal_id: int) -> list[VetVisitResponse]:
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise NotFoundError("Animal not found")
        visits = self.vet_visit_repo.get_by_animal(self.db, animal_id)
        return [self._vet_visit_to_response(v) for v in visits]

    def update_vet_visit(self, visit_id: int, data: VetVisitUpdate, shelter_id: int) -> VetVisitResponse:
        visit = self.vet_visit_repo.get_by_id(self.db, visit_id)
        if not visit:
            raise NotFoundError("Vet visit not found")
        self._validate_animal_belongs_to_shelter(visit.animal_id, shelter_id)
        update_data = data.model_dump(exclude_unset=True)
        updated = self.vet_visit_repo.update(self.db, visit_id, update_data)
        return self._vet_visit_to_response(updated)

    def delete_vet_visit(self, visit_id: int, shelter_id: int) -> None:
        visit = self.vet_visit_repo.get_by_id(self.db, visit_id)
        if not visit:
            raise NotFoundError("Vet visit not found")
        self._validate_animal_belongs_to_shelter(visit.animal_id, shelter_id)
        self.vet_visit_repo.delete(self.db, visit_id)