import pytest
from unittest.mock import MagicMock
from datetime import datetime, date
from fastapi import status
from app.main import app
from app.routers.medical_router import get_medical_service
from app.core.dependencies.role_dependencies import get_current_user, require_manager

mock_user = MagicMock()
mock_user.id = 1
mock_auth = MagicMock()
mock_auth.user = mock_user
mock_auth.shelter_id = 1
mock_auth.role = "MANAGER"


def _medicine_response(**overrides):
    data = {
        "id": 1,
        "name": "Amoxicillin",
        "current_stock": 10,
    }
    data.update(overrides)
    return data


def _treatment_response(**overrides):
    data = {
        "id": 1,
        "animal_id": 1,
        "medicine_id": 1,
        "medicine_name": "Amoxicillin",
        "frequency": "DAILY",
        "status": "PENDING",
        "status_updated_at": "2026-01-01T00:00:00",
        "status_last_updated_by_name": None,
        "start_date": "2026-01-01",
        "end_date": None,
        "dosage": 10.0,
        "dosage_unit": "MG",
    }
    data.update(overrides)
    return data


def _vet_visit_response(**overrides):
    data = {
        "id": 1,
        "animal_id": 1,
        "visit_date": "2026-01-01",
        "visit_type": "GENERAL_CHECKUP",
        "clinic_name": "Vet Clinic",
        "notes": None,
    }
    data.update(overrides)
    return data


@pytest.fixture
def mock_service():
    return MagicMock()


@pytest.fixture(autouse=True)
def setup_overrides(mock_service):
    app.dependency_overrides[get_medical_service] = lambda: mock_service
    app.dependency_overrides[require_manager] = lambda: mock_auth
    app.dependency_overrides[get_current_user] = lambda: mock_auth
    yield
    app.dependency_overrides = {}


# MEDICINES
def test_create_medicine_success(client, mock_service):
    mock_service.create_medicine.return_value = _medicine_response()

    response = client.post("/medical/medicines", json={
        "name": "Amoxicillin",
        "current_stock": 10,
    })

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["name"] == "Amoxicillin"
    mock_service.create_medicine.assert_called_once()


def test_create_medicine_error(client, mock_service):
    mock_service.create_medicine.side_effect = ValueError("Medicine already exists")

    response = client.post("/medical/medicines", json={
        "name": "Amoxicillin",
        "current_stock": 10,
    })

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_medicines_success(client, mock_service):
    mock_service.get_all_medicines.return_value = [_medicine_response()]

    response = client.get("/medical/medicines")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["medicines"]) == 1
    mock_service.get_all_medicines.assert_called_once_with(1)


def test_get_medicine_success(client, mock_service):
    mock_service.get_medicine_by_id.return_value = _medicine_response()

    response = client.get("/medical/medicines/1")

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["id"] == 1
    mock_service.get_medicine_by_id.assert_called_once_with(1, 1)


def test_get_medicine_error(client, mock_service):
    mock_service.get_medicine_by_id.side_effect = ValueError("Medicine is unavailable")

    response = client.get("/medical/medicines/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_update_medicine_success(client, mock_service):
    mock_service.update_medicine.return_value = _medicine_response(name="Updated")

    response = client.patch("/medical/medicines/1", json={"name": "Updated"})

    assert response.status_code == status.HTTP_200_OK
    assert response.json()["name"] == "Updated"
    mock_service.update_medicine.assert_called_once()


def test_delete_medicine_success(client, mock_service):
    response = client.delete("/medical/medicines/1")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_service.delete_medicine.assert_called_once_with(1, 1)


def test_delete_medicine_error(client, mock_service):
    mock_service.delete_medicine.side_effect = ValueError("Medicine is already deleted")

    response = client.delete("/medical/medicines/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


# TREATMENTS
def test_create_treatment_success(client, mock_service):
    mock_service.create_treatment.return_value = _treatment_response()

    response = client.post("/medical/treatments", json={
        "animal_id": 1,
        "medicine_id": 1,
        "frequency": "DAILY",
        "start_date": "2026-01-01",
        "dosage": 10.0,
        "dosage_unit": "MG",
    })

    assert response.status_code == status.HTTP_200_OK
    mock_service.create_treatment.assert_called_once()


def test_create_treatment_error(client, mock_service):
    mock_service.create_treatment.side_effect = ValueError("Animal is invalid")

    response = client.post("/medical/treatments", json={
        "animal_id": 999,
        "medicine_id": 1,
        "frequency": "DAILY",
        "start_date": "2026-01-01",
        "dosage": 10.0,
        "dosage_unit": "MG",
    })

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_treatments_success(client, mock_service):
    mock_service.get_treatments_by_animal.return_value = [_treatment_response()]

    response = client.get("/medical/treatments/1")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["medical_treatments"]) == 1
    mock_service.get_treatments_by_animal.assert_called_once_with(1)


def test_update_treatment_success(client, mock_service):
    mock_service.update_treatment.return_value = _treatment_response(dosage=20.0)

    response = client.patch("/medical/treatments/1", json={"dosage": 20.0})

    assert response.status_code == status.HTTP_200_OK
    mock_service.update_treatment.assert_called_once()


def test_delete_treatment_success(client, mock_service):
    response = client.delete("/medical/treatments/1")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_service.delete_treatment.assert_called_once_with(1, 1)


# VET VISITS
def test_create_vet_visit_success(client, mock_service):
    mock_service.create_vet_visit.return_value = _vet_visit_response()

    response = client.post("/medical/vet-visits", json={
        "animal_id": 1,
        "visit_date": "2026-01-01",
        "visit_type": "GENERAL_CHECKUP",
        "clinic_name": "Vet Clinic",
        "notes": None,
    })

    assert response.status_code == status.HTTP_200_OK
    mock_service.create_vet_visit.assert_called_once()


def test_create_vet_visit_error(client, mock_service):
    mock_service.create_vet_visit.side_effect = ValueError("Animal is invalid")

    response = client.post("/medical/vet-visits", json={
        "animal_id": 999,
        "visit_date": "2026-01-01",
        "visit_type": "GENERAL_CHECKUP",
        "clinic_name": "Vet Clinic",
    })

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_vet_visits_success(client, mock_service):
    mock_service.get_vet_visits_by_animal.return_value = [_vet_visit_response()]

    response = client.get("/medical/vet-visits/1")

    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()["vet_visits"]) == 1
    mock_service.get_vet_visits_by_animal.assert_called_once_with(1)


def test_update_vet_visit_success(client, mock_service):
    mock_service.update_vet_visit.return_value = _vet_visit_response(clinic_name="New Clinic")

    response = client.patch("/medical/vet-visits/1", json={"clinic_name": "New Clinic"})

    assert response.status_code == status.HTTP_200_OK
    mock_service.update_vet_visit.assert_called_once()


def test_delete_vet_visit_success(client, mock_service):
    response = client.delete("/medical/vet-visits/1")

    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_service.delete_vet_visit.assert_called_once_with(1, 1)


def test_delete_vet_visit_error(client, mock_service):
    mock_service.delete_vet_visit.side_effect = ValueError("Visit is already removed")

    response = client.delete("/medical/vet-visits/999")

    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_get_medical_service(db):
    from app.routers.medical_router import get_medical_service
    from app.services.medical_service import MedicalService
    service = get_medical_service(db)
    assert isinstance(service, MedicalService)
