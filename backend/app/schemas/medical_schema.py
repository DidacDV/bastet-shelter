from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

from app.models.medical.medical_treatment import MedicineFrequencyEnum, MedicineStatusEnum, DosageUnitEnum
from app.models.medical.vet_visit import VetVisitTypeEnum


#MEDICINE

class MedicineCreate(BaseModel):
    name: str
    current_stock: int


class MedicineResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    current_stock: int

class MedicineListResponse(BaseModel):
    medicines: list[MedicineResponse]

class MedicineUpdate(BaseModel):
    name: Optional[str] = None
    current_stock: Optional[int] = None


#MEDICAL TREATMENT

class MedicalTreatmentCreate(BaseModel):
    animal_id: int
    medicine_id: int
    frequency: MedicineFrequencyEnum
    status: MedicineStatusEnum = MedicineStatusEnum.PENDING
    start_date: date
    end_date: Optional[date] = None
    dosage: float
    dosage_unit: DosageUnitEnum


class MedicalTreatmentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    animal_id: int
    medicine_id: int
    medicine_name: str
    frequency: MedicineFrequencyEnum
    status: MedicineStatusEnum
    status_updated_at: datetime
    start_date: date
    end_date: Optional[date]
    dosage: float
    dosage_unit: DosageUnitEnum


class MedicalTreatmentUpdate(BaseModel):
    medicine_id: Optional[int] = None
    frequency: Optional[MedicineFrequencyEnum] = None
    status: Optional[MedicineStatusEnum] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None


#VET VISIT

class VetVisitCreate(BaseModel):
    animal_id: int
    visit_date: date
    visit_type: VetVisitTypeEnum
    clinic_name: str
    notes: Optional[str] = None


class VetVisitResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    animal_id: int
    visit_date: date
    visit_type: VetVisitTypeEnum
    clinic_name: str
    notes: Optional[str]


class VetVisitUpdate(BaseModel):
    visit_date: Optional[date] = None
    visit_type: Optional[VetVisitTypeEnum] = None
    clinic_name: Optional[str] = None
    notes: Optional[str] = None
