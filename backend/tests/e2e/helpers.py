"""Shared helpers for API-level end-to-end tests."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.models.adoption.adoption_steps.magic_link_token import MagicLinkToken


def auth_headers(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def register_user(
    client,
    *,
    email: str = "manager@example.com",
    name: str = "Manager",
    password: str = "secret123",
) -> str:
    client.post(
        "/auth/register",
        json={
            "name": name,
            "last_name_1": "Doe",
            "email": email,
            "password": password,
        },
    )
    response = client.post(
        "/auth/login",
        data={"username": email, "password": password},
    )
    assert response.status_code == 200, response.text
    return response.json()["access_token"]


def create_shelter(
    client,
    token: str,
    *,
    name: str = "Rodamons",
    province_id: str = "08",
    refuge_name: str = "Main Refuge",
    shelter_email: str | None = None,
) -> tuple[str, dict]:
    """Create a shelter and return the manager token plus the API response body."""
    if shelter_email is None:
        shelter_email = f"{name.lower().replace(' ', '_')}@example.com"

    response = client.post(
        "/shelters/",
        json={
            "name": name,
            "province_id": province_id,
            "refuge_name": refuge_name,
            "shelter_email": shelter_email,
        },
        headers=auth_headers(token),
    )
    assert response.status_code == 201, response.text
    data = response.json()
    return data["access_token"], data["shelter"]


def get_refuge_id(client, manager_token: str) -> int:
    response = client.get("/shelters/info", headers=auth_headers(manager_token))
    assert response.status_code == 200, response.text
    refuges = response.json()["refuges"]
    assert refuges, "Shelter should have at least one refuge"
    return refuges[0]["id"]


def get_adoptant_token(
    client,
    db: Session,
    *,
    email: str,
    name: str,
) -> str:
    response = client.post(
        "/adoption-auth/request-access",
        json={"email": email, "name": name},
    )
    assert response.status_code == 200, response.text

    magic_link = (
        db.query(MagicLinkToken)
        .order_by(MagicLinkToken.id.desc())
        .first()
    )
    assert magic_link is not None, "Magic link token should be stored in the database"

    verify_response = client.get(f"/adoption-auth/verify?token={magic_link.token}")
    assert verify_response.status_code == 200, verify_response.text
    return verify_response.json()["access_token"]
