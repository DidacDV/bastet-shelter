"""
HTTP -> router -> service -> repository -> database where only external integrations (email,Cloudinary) are mocked (for now?).
"""

from __future__ import annotations

from datetime import date, datetime
from io import BytesIO
from unittest.mock import patch, AsyncMock

import pytest

from tests.e2e.helpers import (
    auth_headers,
    create_shelter,
    get_adoptant_token,
    get_refuge_id,
    register_user,
)


@pytest.mark.e2e
def test_e2e_shelter_onboarding_flow(client, db):
    """
    A new manager registers, creates a shelter, and gets the app working
    with default traits and the first refuge.
    """
    token = register_user(client, email="owner@example.com", name="Owner")

    no_membership = client.get("/shelters/me", headers=auth_headers(token))
    assert no_membership.status_code == 404

    manager_token, shelter = create_shelter(
        client,
        token,
        name="Bastet Hope",
        refuge_name="Centre Barcelona",
        shelter_email="contact@bastethope.com",
    )

    membership = client.get("/shelters/me", headers=auth_headers(manager_token))
    assert membership.status_code == 200
    assert membership.json()["name"] == "Bastet Hope"
    assert membership.json()["role"] == "MANAGER"

    shelter_info = client.get("/shelters/info", headers=auth_headers(manager_token))
    assert shelter_info.status_code == 200
    info = shelter_info.json()
    assert info["name"] == "Bastet Hope"
    assert info["shelter_email"] == "contact@bastethope.com"
    assert len(info["refuges"]) == 1
    assert info["refuges"][0]["name"] == "Centre Barcelona"

    traits = client.get("/traits/", headers=auth_headers(manager_token))
    assert traits.status_code == 200
    trait_names = {trait["name"] for trait in traits.json()["traits"]}
    assert trait_names == {"Friendly", "Playful", "Shy", "Calm", "Energetic"}

    assert shelter["id"] == info["id"]


@pytest.mark.e2e
@patch("app.services.animal_service.cloudinary_uploader.upload")
def test_e2e_register_animal_with_traits_and_photo(mock_cloudinary_upload, client):
    """
    A manager registers an animal, assigns personality traits, uploads a photo,
    and the animal becomes visible internally and on the public adoption portal
    once marked as available for adoption.
    """
    mock_cloudinary_upload.return_value = {
        "secure_url": "https://cdn.example.com/animals/luna.jpg",
        "public_id": "shelters/1/animals/1/luna",
    }

    token = register_user(client, email="manager@example.com")
    manager_token, _ = create_shelter(client, token)
    refuge_id = get_refuge_id(client, manager_token)

    traits_response = client.get("/traits/", headers=auth_headers(manager_token))
    traits = traits_response.json()["traits"]
    friendly = next(t for t in traits if t["name"] == "Friendly")
    playful = next(t for t in traits if t["name"] == "Playful")

    create_animal = client.post(
        "/animals/",
        json={
            "name": "Luna",
            "birth_date": "2022-03-15",
            "arrival_date": "2025-01-10",
            "description": "Very social cat looking for a calm home.",
            "breed": "European Shorthair",
            "animal_type": "CAT",
            "refuge_id": refuge_id,
            "trait_ids": [friendly["id"], playful["id"]],
        },
        headers=auth_headers(manager_token),
    )
    assert create_animal.status_code == 200, create_animal.text
    animal_id = create_animal.json()["id"]

    upload_photo = client.post(
        f"/animals/{animal_id}/images",
        headers=auth_headers(manager_token),
        files={"file": ("luna.jpg", BytesIO(b"fake-image-bytes"), "image/jpeg")},
    )
    assert upload_photo.status_code == 200, upload_photo.text
    assert upload_photo.json()["url"] == "https://cdn.example.com/animals/luna.jpg"

    animal_detail = client.get(
        f"/animals/{animal_id}",
        headers=auth_headers(manager_token),
    )
    assert animal_detail.status_code == 200
    detail = animal_detail.json()
    assert detail["name"] == "Luna"
    assert {trait["name"] for trait in detail["traits"]} == {"Friendly", "Playful"}
    assert len(detail["images"]) == 1
    assert detail["in_adoption"] is False

    portal_before = client.get("/animals/short_info_portal?province_id=08")
    assert portal_before.status_code == 200
    assert all(animal["name"] != "Luna" for animal in portal_before.json()["animals"])

    toggle_adoption = client.patch(
        f"/animals/{animal_id}/adoption",
        headers=auth_headers(manager_token),
    )
    assert toggle_adoption.status_code == 200
    assert toggle_adoption.json()["in_adoption"] is True

    public_detail = client.get(f"/animals/public/{animal_id}")
    assert public_detail.status_code == 200
    public = public_detail.json()
    assert public["name"] == "Luna"
    assert public["in_adoption"] is True
    assert {trait["name"] for trait in public["traits"]} == {"Friendly", "Playful"}
    assert len(public["images"]) == 1

    portal_after = client.get("/animals/short_info_portal?province_id=08")
    assert portal_after.status_code == 200
    portal_names = {animal["name"] for animal in portal_after.json()["animals"]}
    assert "Luna" in portal_names


@pytest.mark.e2e
@patch("fastapi_mail.FastMail.send_message", new_callable=AsyncMock)
@patch("app.services.adoption_process_service.send_email")
def test_e2e_adoption_process_from_portal_to_shelter_review(mock_fastmail_send ,mock_send_email, client, db):
    """
    An adoptant authenticates with a magic link, submits an adoption form for
    a published animal, and both the adoptant and the shelter can see the new
    active process with its initial workflow steps.
    """
    manager_token = _setup_animal_ready_for_adoption(client)
    animal_id = _register_simple_animal(client, manager_token)

    toggle = client.patch(
        f"/animals/{animal_id}/adoption",
        headers=auth_headers(manager_token),
    )
    assert toggle.status_code == 200

    adoptant_token = get_adoptant_token(
        client,
        db,
        email="adoptant@example.com",
        name="Anna Adoptant",
    )

    start_process = client.post(
        f"/adoption/start/{animal_id}",
        headers=auth_headers(adoptant_token),
        json={
            "housing_type": "Flat",
            "has_garden": False,
            "has_other_pets": False,
            "has_children": True,
            "children_ages": "6 and 9",
            "previous_pet_experience": True,
            "hours_alone_per_day": 3,
            "reason_for_adoption": "We want to give a rescued cat a stable home.",
        },
    )
    assert start_process.status_code == 201, start_process.text
    process = start_process.json()
    assert process["status"] == "ACTIVE"
    assert process["animal_name"] == "Milo"
    assert len(process["steps"]) == 5
    assert process["steps"][0]["type"] == "FORM"
    assert process["steps"][0]["status"] == "PENDING"

    adoptant_processes = client.get(
        "/adoptant/processes",
        headers=auth_headers(adoptant_token),
    )
    assert adoptant_processes.status_code == 200
    assert len(adoptant_processes.json()) == 1
    assert adoptant_processes.json()[0]["id"] == process["id"]

    shelter_processes = client.get(
        "/adoption/shelter",
        headers=auth_headers(manager_token),
    )
    assert shelter_processes.status_code == 200
    shelter_list = shelter_processes.json()["processes"]
    assert len(shelter_list) == 1
    assert shelter_list[0]["id"] == process["id"]
    assert shelter_list[0]["adoptant_name"] == "Anna Adoptant"

    manager_detail = client.get(
        f"/adoption/{process['id']}/manager",
        headers=auth_headers(manager_token),
    )
    assert manager_detail.status_code == 200
    current_steps = [
        step for step in manager_detail.json()["steps"] if step.get("is_current")
    ]
    assert len(current_steps) == 1
    assert current_steps[0]["type"] == "FORM"

    assert mock_send_email.called


@pytest.mark.e2e
def test_e2e_volunteer_joins_shift_and_gets_assigned_task(client):
    """
    A volunteer joins a shelter, a manager creates a reusable task and a shift,
    the volunteer joins the shift, and the shift detail shows that the volunteer has joined.
    """
    owner_token = register_user(client, email="owner@example.com", name="Owner")
    manager_token, shelter = create_shelter(client, owner_token)
    refuge_id = get_refuge_id(client, manager_token)
    volunteer_code = shelter["volunteer_code"]

    volunteer_login = register_user(
        client,
        email="volunteer@example.com",
        name="Volunteer",
    )
    join_response = client.post(
        f"/shelters/join/volunteer/{volunteer_code}",
        headers=auth_headers(volunteer_login),
    )
    assert join_response.status_code == 201, join_response.text
    volunteer_token = join_response.json()["access_token"]

    create_task = client.post(
        "/tasks/",
        json={
            "title": "Clean cat area",
            "description": "Sweep, refill water and check litter boxes.",
            "num_people": 2,
        },
        headers=auth_headers(manager_token),
    )
    assert create_task.status_code == 200, create_task.text
    task_id = create_task.json()["id"]

    shift_day = date(2026, 5, 25)
    create_shift = client.post(
        f"/shifts/?refuge_id={refuge_id}",
        json={
            "start_time": datetime(2026, 5, 25, 9, 0).isoformat(),
            "end_time": datetime(2026, 5, 25, 12, 0).isoformat(),
            "day": shift_day.isoformat(),
            "max_participants": 3,
            "task_ids": [task_id],
        },
        headers=auth_headers(manager_token),
    )
    assert create_shift.status_code == 200, create_shift.text
    shift_id = create_shift.json()["id"]

    join_shift = client.post(
        f"/shifts/{shift_id}/join",
        headers=auth_headers(volunteer_token),
    )
    assert join_shift.status_code == 200, join_shift.text
    participant_id = join_shift.json()["id"]

    shift_detail = client.get(
        f"/shifts/{shift_id}",
        headers=auth_headers(volunteer_token),
    )
    assert shift_detail.status_code == 200
    detail = shift_detail.json()
    assert detail["is_joined"] is True
    assert detail["my_participant_id"] == participant_id
    assert len(detail["shift_tasks"]) == 1
    assert detail["shift_tasks"][0]["task"]["title"] == "Clean cat area"

    manager_view = client.get(
        f"/shifts/{shift_id}",
        headers=auth_headers(manager_token),
    )
    assert manager_view.status_code == 200
    assert manager_view.json()["current_participants"] == 1


@pytest.mark.e2e
def test_e2e_external_adoption_link_by_name(client):
    manager_token = _setup_animal_ready_for_adoption(client)
    animal_id = _register_simple_animal(client, manager_token)

    client.patch(f"/animals/{animal_id}/adoption", headers=auth_headers(manager_token))

    animal = client.get(
        f"/animals/{animal_id}",
        headers=auth_headers(manager_token),
    ).json()
    shelter_link_name = client.get("/shelters/info", headers=auth_headers(manager_token)).json()["link_name"]

    public = client.get(
        f"/animals/public/by-link/{shelter_link_name}/{animal['link_name']}"
    )
    assert public.status_code == 200
    assert public.json()["name"] == "Milo"
    assert public.json()["link_name"] == "milo"
    assert public.json()["shelter_link_name"] == shelter_link_name

    integration = client.get("/shelters/integration", headers=auth_headers(manager_token))
    assert integration.status_code == 200
    assert shelter_link_name in integration.json()["url_pattern"]
    assert animal["adoption_url"].endswith(f"/adopt/{shelter_link_name}/{animal['link_name']}")


def _setup_animal_ready_for_adoption(client) -> str:
    token = register_user(client, email="manager-adopt@example.com")
    manager_token, _ = create_shelter(
        client,
        token,
        name="Adoption Shelter",
        shelter_email="adoption@shelter.com",
    )
    return manager_token


def _register_simple_animal(client, manager_token: str) -> int:
    refuge_id = get_refuge_id(client, manager_token)
    response = client.post(
        "/animals/",
        json={
            "name": "Milo",
            "birth_date": "2021-06-01",
            "description": "Calm dog ready for adoption.",
            "breed": "Mixed",
            "animal_type": "DOG",
            "refuge_id": refuge_id,
            "trait_ids": [],
        },
        headers=auth_headers(manager_token),
    )
    assert response.status_code == 200, response.text
    return response.json()["id"]
