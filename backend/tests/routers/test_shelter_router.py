def _register_and_login(client, email="user@example.com", name="John"):
    client.post("/auth/register", json={
        "name": name,
        "last_name_1": "Doe",
        "email": email,
        "password": "secret123",
    })
    res = client.post("/auth/login", data={
        "username": email,
        "password": "secret123",
    })
    return res.json()["access_token"]

def _auth_headers(token):
    return {"Authorization": f"Bearer {token}"}

def _create_shelter(
    client,
    token,
    name="Rodamons",
    province_id="08",
    refuge_name="refuge",
    shelter_email=None,
):
    """Helper that returns (new_token, volunteer_code, manager_code, shelter_id)"""
    if shelter_email is None:
        shelter_email = f"{name.lower().replace(' ', '_')}@example.com"
    res = client.post(
        "/shelters/",
        json={
            "name": name,
            "province_id": province_id,
            "refuge_name": refuge_name,
            "shelter_email": shelter_email,
        },
        headers=_auth_headers(token)
    )
    assert res.status_code == 201, res.json()
    data = res.json()
    return data["access_token"], data["shelter"]["volunteer_code"], data["shelter"]["manager_code"], data["shelter"]["id"]

def test_create_shelter(client):
    token = _register_and_login(client)
    new_token, volunteer_code, manager_code, shelter_id = _create_shelter(client, token)
    assert new_token is not None
    assert volunteer_code is not None
    assert manager_code is not None
    assert shelter_id is not None

def test_create_shelter_unauthenticated(client):
    res = client.post("/shelters/", json={"name": "Happy Paws", "province_id": "08"})
    assert res.status_code == 401


def test_create_shelter_requires_email(client):
    token = _register_and_login(client)
    res = client.post(
        "/shelters/",
        json={"name": "Happy Paws", "province_id": "08", "refuge_name": "Main"},
        headers=_auth_headers(token),
    )
    assert res.status_code == 422


def test_create_shelter_duplicate_email(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    _create_shelter(client, owner_token, shelter_email="contact@rodamons.com")

    other_token = _register_and_login(client, email="other@example.com", name="Other")
    res = client.post(
        "/shelters/",
        json={
            "name": "Another Shelter",
            "province_id": "08",
            "refuge_name": "Refuge",
            "shelter_email": "contact@rodamons.com",
        },
        headers=_auth_headers(other_token),
    )
    assert res.status_code == 400
    assert res.json()["detail"] == "A shelter with this email already exists"

def test_get_my_membership_no_shelter(client):
    token = _register_and_login(client)
    res = client.get("/shelters/me", headers=_auth_headers(token))
    assert res.status_code == 404

def test_get_my_membership(client):
    token = _register_and_login(client)
    new_token, _, _, _ = _create_shelter(client, token)
    res = client.get("/shelters/me", headers=_auth_headers(new_token))
    assert res.status_code == 200

def test_join_as_volunteer(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    _, volunteer_code, _, _ = _create_shelter(client, owner_token)

    volunteer_token = _register_and_login(client, email="volunteer@example.com", name="Volunteer")
    res = client.post(f"/shelters/join/volunteer/{volunteer_code}", headers=_auth_headers(volunteer_token))
    assert res.status_code == 201

def test_join_as_volunteer_invalid_code(client):
    token = _register_and_login(client)
    res = client.post("/shelters/join/volunteer/badcode", headers=_auth_headers(token))
    assert res.status_code == 404

def test_join_as_manager(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    _, _, manager_code, _ = _create_shelter(client, owner_token)

    manager_token = _register_and_login(client, email="manager@example.com", name="Manager")
    res = client.post(f"/shelters/join/manager/{manager_code}", headers=_auth_headers(manager_token))
    assert res.status_code == 201

def test_join_as_manager_invalid_code(client):
    token = _register_and_login(client)
    res = client.post("/shelters/join/manager/badcode", headers=_auth_headers(token))
    assert res.status_code == 404


# region RESET_CODES

def test_reset_volunteer_code(client):
    token = _register_and_login(client)
    manager_token, _, _, _ = _create_shelter(client, token)
    res = client.post("/shelters/reset/volunteer", headers=_auth_headers(manager_token))
    assert res.status_code == 200


def test_reset_manager_code(client):
    token = _register_and_login(client)
    manager_token, _, _, _ = _create_shelter(client, token)
    res = client.post("/shelters/reset/manager", headers=_auth_headers(manager_token))
    assert res.status_code == 200


def test_reset_codes_requires_auth(client):
    assert client.post("/shelters/reset/volunteer").status_code == 401
    assert client.post("/shelters/reset/manager").status_code == 401


def test_volunteer_cannot_reset_codes(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    _, volunteer_code, _, _ = _create_shelter(client, owner_token)

    volunteer_token = _register_and_login(client, email="vol@example.com", name="Vol")
    join_res = client.post(f"/shelters/join/volunteer/{volunteer_code}", headers=_auth_headers(volunteer_token))
    vol_token = join_res.json()["access_token"]

    assert client.post("/shelters/reset/volunteer", headers=_auth_headers(vol_token)).status_code == 403
    assert client.post("/shelters/reset/manager", headers=_auth_headers(vol_token)).status_code == 403

def test_get_shelter_basic_info(client):
    token = _register_and_login(client)
    manager_token, _, _, _ = _create_shelter(client, token, name="Shelter X", refuge_name="Main Refuge")
    
    res = client.get("/shelters/info", headers=_auth_headers(manager_token))
    assert res.status_code == 200
    data = res.json()
    assert data["name"] == "Shelter X"
    assert "refuges" in data
    assert len(data["refuges"]) == 1
    assert data["refuges"][0]["name"] == "Main Refuge"


def test_update_shelter(client):
    token = _register_and_login(client)
    manager_token, _, _, shelter_id = _create_shelter(client, token, name="Old Name", province_id="08")

    res = client.put(
        f"/shelters/",
        json={"name": "New Name", "province_id": "08"},
        headers=_auth_headers(manager_token)
    )
    assert res.status_code == 200
    data = res.json()
    assert data["name"] == "New Name"
    assert data["province"]["id"] == "08"


def test_update_shelter_partial(client):
    token = _register_and_login(client)
    manager_token, _, _, shelter_id = _create_shelter(client, token, name="Old Name", province_id="08")

    res = client.put(
        f"/shelters/",
        json={"name": "Updated Name"},
        headers=_auth_headers(manager_token)
    )
    assert res.status_code == 200
    data = res.json()
    assert data["name"] == "Updated Name"
    assert data["province"]["id"] == "08"


def test_update_shelter_duplicate_email(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    manager_token, _, _, _ = _create_shelter(
        client,
        owner_token,
        name="Shelter A",
        shelter_email="shelter_a@example.com",
    )

    other_token = _register_and_login(client, email="other@example.com", name="Other")
    other_manager_token, _, _, _ = _create_shelter(
        client,
        other_token,
        name="Shelter B",
        shelter_email="shelter_b@example.com",
    )

    res = client.put(
        "/shelters/",
        json={"email": "shelter_a@example.com"},
        headers=_auth_headers(other_manager_token),
    )
    assert res.status_code == 400
    assert res.json()["detail"] == "A shelter with this email already exists"


def test_update_shelter_unauthorized(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    _, volunteer_code, _, _ = _create_shelter(client, owner_token)

    volunteer_token = _register_and_login(client, email="vol@example.com", name="Vol")
    join_res = client.post(f"/shelters/join/volunteer/{volunteer_code}", headers=_auth_headers(volunteer_token))
    vol_token = join_res.json()["access_token"]

    res = client.put(
        "/shelters/",
        json={"name": "New Name"},
        headers=_auth_headers(vol_token)
    )
    assert res.status_code == 403

# endregion