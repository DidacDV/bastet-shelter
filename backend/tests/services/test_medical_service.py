import pytest
from unittest.mock import MagicMock
from datetime import date, datetime

from app.core.exceptions import AuthorizationError, BusinessLogicError, NotFoundError
from app.models.medical.medicine import Medicine
from app.models.medical.medical_treatment import AnimalTreatment
from app.models.medical.vet_visit import VetVisit
from app.services.medical_service import MedicalService
from app.schemas.medical_schema import (
    MedicineCreate, MedicineUpdate,
    MedicalTreatmentCreate, MedicalTreatmentUpdate,
    VetVisitCreate, VetVisitUpdate,
)


@pytest.fixture
def service():
    db = MagicMock()
    s = MedicalService(db)
    s.medicine_repo = MagicMock()
    s.treatment_repo = MagicMock()
    s.vet_visit_repo = MagicMock()
    s.animal_repo = MagicMock()
    s.refuge_repo = MagicMock()
    return s


def setup_auth_mocks(service, shelter_id=1):
    mock_animal = MagicMock()
    mock_animal.refuge_id = 1
    service.animal_repo.get_by_id.return_value = mock_animal

    mock_refuge = MagicMock()
    mock_refuge.shelter_id = shelter_id
    service.refuge_repo.get_by_id.return_value = mock_refuge

def test_delete_medicine_success(service):
    medicine_id = 1
    shelter_id = 1
    mock_medicine = MagicMock(spec=Medicine)
    mock_medicine.shelter_id = shelter_id

    service.medicine_repo.get_by_id.return_value = mock_medicine
    service.medicine_repo.is_used_in_active_treatment.return_value = False

    service.delete_medicine(medicine_id, shelter_id)

    service.medicine_repo.delete.assert_called_once_with(service.db, medicine_id)


def test_delete_medicine_not_found(service):
    service.medicine_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError):
        service.delete_medicine(1, 1)


def test_delete_medicine_wrong_shelter(service):
    mock_medicine = MagicMock(spec=Medicine)
    mock_medicine.shelter_id = 2
    service.medicine_repo.get_by_id.return_value = mock_medicine

    with pytest.raises(AuthorizationError):
        service.delete_medicine(1, 1)


def test_delete_medicine_used_in_active_treatment(service):
    mock_medicine = MagicMock(spec=Medicine)
    mock_medicine.shelter_id = 1
    service.medicine_repo.get_by_id.return_value = mock_medicine
    service.medicine_repo.is_used_in_active_treatment.return_value = True

    with pytest.raises(BusinessLogicError) as excinfo:
        service.delete_medicine(1, 1)

    assert "active" in excinfo.value.message.lower()
    assert "treatment" in excinfo.value.message.lower()
    service.medicine_repo.delete.assert_not_called()


def test_create_medicine_success(service):
    data = MedicineCreate(name="Aspirin", current_stock=10)
    service.medicine_repo.get_by_name_and_shelter.return_value = None

    mock_created = MagicMock(spec=Medicine)
    mock_created.id = 1
    mock_created.name = "Aspirin"
    mock_created.current_stock = 10
    service.medicine_repo.create.return_value = mock_created

    result = service.create_medicine(data, 1)

    assert result.id == 1
    assert result.name == "Aspirin"
    service.medicine_repo.create.assert_called_once()


def test_create_medicine_duplicate(service):
    data = MedicineCreate(name="Aspirin", current_stock=10)
    service.medicine_repo.get_by_name_and_shelter.return_value = MagicMock()

    with pytest.raises(BusinessLogicError):
        service.create_medicine(data, 1)


def test_get_all_medicines(service):
    mock_med = MagicMock(spec=Medicine)
    mock_med.id = 1
    mock_med.name = "Aspirin"
    mock_med.current_stock = 10
    service.medicine_repo.get_by_shelter.return_value = [mock_med]

    result = service.get_all_medicines(1)

    assert len(result) == 1
    assert result[0].id == 1


def test_get_medicine_by_id_success(service):
    mock_med = MagicMock(spec=Medicine)
    mock_med.id = 1
    mock_med.name = "Aspirin"
    mock_med.current_stock = 5
    mock_med.shelter_id = 1
    service.medicine_repo.get_by_id.return_value = mock_med

    result = service.get_medicine_by_id(1, 1)

    assert result.id == mock_med.id


def test_update_medicine_success(service):
    data = MedicineUpdate(name="Ibuprofen")
    mock_med = MagicMock(spec=Medicine)
    mock_med.name = "Aspirin"
    mock_med.shelter_id = 1
    service.medicine_repo.get_by_id.return_value = mock_med
    service.medicine_repo.get_by_name_and_shelter.return_value = None

    mock_updated = MagicMock(spec=Medicine)
    mock_updated.id = 1
    mock_updated.name = "Ibuprofen"
    mock_updated.current_stock = 10
    service.medicine_repo.update.return_value = mock_updated

    result = service.update_medicine(1, data, 1)

    assert result.name == "Ibuprofen"


def test_update_medicine_duplicate_name(service):
    data = MedicineUpdate(name="Ibuprofen")
    mock_med = MagicMock(spec=Medicine)
    mock_med.name = "Aspirin"
    mock_med.shelter_id = 1
    service.medicine_repo.get_by_id.return_value = mock_med
    service.medicine_repo.get_by_name_and_shelter.return_value = MagicMock()

    with pytest.raises(BusinessLogicError):
        service.update_medicine(1, data, 1)

def test_create_treatment_success(service):
    setup_auth_mocks(service, 1)

    data = MedicalTreatmentCreate(
        animal_id=1,
        medicine_id=1,
        frequency="DAILY",
        start_date=date(2026, 1, 1),
        dosage=1.5,
        dosage_unit="MG"
    )

    service.medicine_repo.get_by_id.return_value = MagicMock()

    mock_created = MagicMock(spec=AnimalTreatment)
    mock_created.id = 1
    mock_created.animal_id = 1
    mock_created.medicine_id = 1
    mock_created.frequency = "DAILY"
    mock_created.status = "PENDING"
    mock_created.status_updated_at = datetime(2026, 1, 1, 12, 0, 0)
    mock_created.start_date = date(2026, 1, 1)
    mock_created.end_date = None
    mock_created.dosage = 1.5
    mock_created.dosage_unit = "MG"
    mock_created.status_last_updated_by_name = None
    mock_created.medicine = MagicMock()
    mock_created.medicine.name = "Aspirin"
    service.treatment_repo.create.return_value = mock_created

    result = service.create_treatment(data, 1)

    assert result.id == 1
    service.treatment_repo.create.assert_called_once()


def test_create_treatment_unauthorized(service):
    setup_auth_mocks(service, 2)
    data = MedicalTreatmentCreate(animal_id=1, medicine_id=1, frequency="DAILY", start_date=date.today(), dosage=1.0,
                                  dosage_unit="MG")

    with pytest.raises(AuthorizationError):
        service.create_treatment(data, 1)


def test_create_treatment_medicine_not_found(service):
    setup_auth_mocks(service, 1)
    data = MedicalTreatmentCreate(animal_id=1, medicine_id=1, frequency="DAILY", start_date=date.today(), dosage=1.0,
                                  dosage_unit="MG")
    service.medicine_repo.get_by_id.return_value = None

    with pytest.raises(NotFoundError):
        service.create_treatment(data, 1)


def test_get_treatments_by_animal_success(service):
    service.animal_repo.get_by_id.return_value = MagicMock()

    mock_treatment = MagicMock(spec=AnimalTreatment)
    mock_treatment.id = 1
    mock_treatment.animal_id = 1
    mock_treatment.medicine_id = 1
    mock_treatment.frequency = "DAILY"
    mock_treatment.status = "PENDING"
    mock_treatment.status_updated_at = datetime(2026, 1, 1, 12, 0, 0)
    mock_treatment.start_date = date(2026, 1, 1)
    mock_treatment.end_date = None
    mock_treatment.dosage = 1.0
    mock_treatment.dosage_unit = "MG"
    mock_treatment.status_last_updated_by_name = "System"
    mock_treatment.medicine = MagicMock()
    mock_treatment.medicine.name = "Aspirin"
    service.treatment_repo.get_by_animal.return_value = [mock_treatment]

    result = service.get_treatments_by_animal(1)

    assert len(result) == 1
    assert result[0].id == 1


def test_update_treatment_success(service):
    setup_auth_mocks(service, 1)
    data = MedicalTreatmentUpdate(frequency="WEEKLY")

    mock_treatment = MagicMock(spec=AnimalTreatment)
    mock_treatment.animal_id = 1
    mock_treatment.status = "PENDING"
    service.treatment_repo.get_by_id.return_value = mock_treatment

    mock_updated = MagicMock(spec=AnimalTreatment)
    mock_updated.id = 1
    mock_updated.animal_id = 1
    mock_updated.medicine_id = 1
    mock_updated.frequency = "WEEKLY"
    mock_updated.status = "PENDING"
    mock_updated.status_updated_at = datetime(2026, 1, 1, 12, 0, 0)
    mock_updated.start_date = date(2026, 1, 1)
    mock_updated.end_date = None
    mock_updated.dosage = 1.0
    mock_updated.dosage_unit = "MG"
    mock_updated.status_last_updated_by_name = None
    mock_updated.medicine = MagicMock()
    mock_updated.medicine.name = "Aspirin"
    service.treatment_repo.update.return_value = mock_updated

    result = service.update_treatment(100, 1, data, 1)

    assert result.id == 1
    service.treatment_repo.update.assert_called_once()


def test_update_treatment_status_change(service):
    setup_auth_mocks(service, 1)
    data = MedicalTreatmentUpdate(status="GIVEN")

    mock_treatment = MagicMock(spec=AnimalTreatment)
    mock_treatment.animal_id = 1
    mock_treatment.status = "PENDING"
    service.treatment_repo.get_by_id.return_value = mock_treatment

    mock_updated = MagicMock(spec=AnimalTreatment)
    mock_updated.id = 1
    mock_updated.animal_id = 1
    mock_updated.medicine_id = 1
    mock_updated.frequency = "DAILY"
    mock_updated.status = "GIVEN"
    mock_updated.status_updated_at = datetime(2026, 1, 1, 12, 0, 0)
    mock_updated.start_date = date(2026, 1, 1)
    mock_updated.end_date = None
    mock_updated.dosage = 1.0
    mock_updated.dosage_unit = "MG"
    mock_updated.status_last_updated_by_name = None
    mock_updated.medicine = MagicMock()
    mock_updated.medicine.name = "Aspirin"
    service.treatment_repo.update.return_value = mock_updated

    service.update_treatment(100, 1, data, 1)

    assert mock_treatment.status_last_updated_by_id == 100


def test_delete_treatment_success(service):
    setup_auth_mocks(service, 1)
    mock_treatment = MagicMock(spec=AnimalTreatment)
    mock_treatment.animal_id = 1
    service.treatment_repo.get_by_id.return_value = mock_treatment

    service.delete_treatment(1, 1)

    service.treatment_repo.delete.assert_called_once_with(service.db, 1)

def test_create_vet_visit_success(service):
    setup_auth_mocks(service, 1)
    data = VetVisitCreate(animal_id=1, visit_date=date(2026, 1, 1), visit_type="GENERAL_CHECKUP",
                          clinic_name="VetClinic")

    mock_created = MagicMock(spec=VetVisit)
    mock_created.id = 1
    mock_created.animal_id = 1
    mock_created.visit_date = date(2026, 1, 1)
    mock_created.visit_type = "GENERAL_CHECKUP"
    mock_created.clinic_name = "VetClinic"
    mock_created.notes = None
    service.vet_visit_repo.create.return_value = mock_created

    result = service.create_vet_visit(data, 1)

    assert result.id == 1


def test_get_vet_visits_by_animal_success(service):
    service.animal_repo.get_by_id.return_value = MagicMock()
    mock_visit = MagicMock(spec=VetVisit)
    mock_visit.id = 1
    mock_visit.animal_id = 1
    mock_visit.visit_date = date(2026, 1, 1)
    mock_visit.visit_type = "GENERAL_CHECKUP"
    mock_visit.clinic_name = "VetClinic"
    mock_visit.notes = "Healthy"
    service.vet_visit_repo.get_by_animal.return_value = [mock_visit]

    result = service.get_vet_visits_by_animal(1)

    assert len(result) == 1
    assert result[0].id == 1


def test_update_vet_visit_success(service):
    setup_auth_mocks(service, 1)
    data = VetVisitUpdate(notes="All good")

    mock_visit = MagicMock(spec=VetVisit)
    mock_visit.animal_id = 1
    service.vet_visit_repo.get_by_id.return_value = mock_visit

    mock_updated = MagicMock(spec=VetVisit)
    mock_updated.id = 1
    mock_updated.animal_id = 1
    mock_updated.visit_date = date(2026, 1, 1)
    mock_updated.visit_type = "GENERAL_CHECKUP"
    mock_updated.clinic_name = "VetClinic"
    mock_updated.notes = "All good"
    service.vet_visit_repo.update.return_value = mock_updated

    result = service.update_vet_visit(1, data, 1)

    assert result.id == 1
    service.vet_visit_repo.update.assert_called_once()


def test_delete_vet_visit_success(service):
    setup_auth_mocks(service, 1)
    mock_visit = MagicMock(spec=VetVisit)
    mock_visit.animal_id = 1
    service.vet_visit_repo.get_by_id.return_value = mock_visit

    service.delete_vet_visit(1, 1)

    service.vet_visit_repo.delete.assert_called_once_with(service.db, 1)