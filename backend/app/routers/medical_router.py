from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, get_current_user, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.medical_schema import (
    MedicineCreate, MedicineResponse, MedicineUpdate,
    MedicalTreatmentCreate, MedicalTreatmentResponse, MedicalTreatmentUpdate,
    VetVisitCreate, VetVisitResponse, VetVisitUpdate, MedicineListResponse, VetVisitListResponse,
    MedicalTreatmentListResponse,
)
from app.services.medical_service import MedicalService

router = APIRouter(prefix="/medical", tags=["medical"])

def get_medical_service(db: Session = Depends(get_db)) -> MedicalService:
    return MedicalService(db)

# MEDICINE
@router.post("/medicines", response_model=MedicineResponse)
def create_medicine(
    data: MedicineCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    return service.create_medicine(data, auth.shelter_id)

@router.get("/medicines", response_model=MedicineListResponse)
def get_medicines(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: MedicalService = Depends(get_medical_service),
):
    return {"medicines": service.get_all_medicines(auth.shelter_id)}

@router.get("/medicines/{medicine_id}", response_model=MedicineResponse)
def get_medicine(
    medicine_id: int,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: MedicalService = Depends(get_medical_service),
):
    return service.get_medicine_by_id(medicine_id, auth.shelter_id)

@router.patch("/medicines/{medicine_id}", response_model=MedicineResponse)
def update_medicine(
    medicine_id: int,
    data: MedicineUpdate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    return service.update_medicine(medicine_id, data, auth.shelter_id)

@router.delete("/medicines/{medicine_id}", status_code=204)
def delete_medicine(
    medicine_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    service.delete_medicine(medicine_id, auth.shelter_id)

# TREATMENT
@router.post("/treatments", response_model=MedicalTreatmentResponse)
def create_treatment(
    data: MedicalTreatmentCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    return service.create_treatment(data, auth.shelter_id)

@router.get("/treatments/{animal_id}", response_model=MedicalTreatmentListResponse)
def get_treatments(
    animal_id: int,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: MedicalService = Depends(get_medical_service),
):
    return {"medical_treatments": service.get_treatments_by_animal(animal_id)}

@router.patch("/treatments/{treatment_id}", response_model=MedicalTreatmentResponse)
def update_treatment(
    treatment_id: int,
    data: MedicalTreatmentUpdate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    return service.update_treatment(auth.user.id, treatment_id, data, auth.shelter_id)

@router.delete("/treatments/{treatment_id}", status_code=204)
def delete_treatment(
    treatment_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    service.delete_treatment(treatment_id, auth.shelter_id)

# VET VISITS
@router.post("/vet-visits", response_model=VetVisitResponse)
def create_vet_visit(
    data: VetVisitCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    return service.create_vet_visit(data, auth.shelter_id)

@router.get("/vet-visits/{animal_id}", response_model=VetVisitListResponse)
def get_vet_visits(
    animal_id: int,
    auth: AuthenticatedUser = Depends(get_current_user),
    service: MedicalService = Depends(get_medical_service),
):
    return {"vet_visits": service.get_vet_visits_by_animal(animal_id)}

@router.patch("/vet-visits/{visit_id}", response_model=VetVisitResponse)
def update_vet_visit(
    visit_id: int,
    data: VetVisitUpdate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    return service.update_vet_visit(visit_id, data, auth.shelter_id)

@router.delete("/vet-visits/{visit_id}", status_code=204)
def delete_vet_visit(
    visit_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: MedicalService = Depends(get_medical_service),
):
    service.delete_vet_visit(visit_id, auth.shelter_id)