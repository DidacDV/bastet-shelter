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

def _create_shelter(client, token, name="Rodamons", location="Barcelona", refuge_name="refuge"):
    """Helper that returns (new_token, volunteer_code, manager_code)"""
    res = client.post(
        "/shelters/",
        json={"name": name, "location": location, "refuge_name": refuge_name},
        headers=_auth_headers(token)
    )
    assert res.status_code == 201, res.json()
    data = res.json()
    return data["access_token"], data["shelter"]["volunteer_code"], data["shelter"]["manager_code"]

def test_create_shelter(client):
    token = _register_and_login(client)
    new_token, volunteer_code, manager_code = _create_shelter(client, token)
    assert new_token is not None
    assert volunteer_code is not None
    assert manager_code is not None

def test_create_shelter_unauthenticated(client):
    res = client.post("/shelters/", json={"name": "Happy Paws", "location": "Barcelona"})
    assert res.status_code == 401

def test_get_my_membership_no_shelter(client):
    token = _register_and_login(client)
    res = client.get("/shelters/me", headers=_auth_headers(token))
    assert res.status_code == 404

def test_get_my_membership(client):
    token = _register_and_login(client)
    new_token, _, _ = _create_shelter(client, token)
    res = client.get("/shelters/me", headers=_auth_headers(new_token))
    assert res.status_code == 200

def test_join_as_volunteer(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    _, volunteer_code, _ = _create_shelter(client, owner_token)

    volunteer_token = _register_and_login(client, email="volunteer@example.com", name="Volunteer")
    res = client.post(f"/shelters/join/volunteer/{volunteer_code}", headers=_auth_headers(volunteer_token))
    assert res.status_code == 201

def test_join_as_volunteer_invalid_code(client):
    token = _register_and_login(client)
    res = client.post("/shelters/join/volunteer/badcode", headers=_auth_headers(token))
    assert res.status_code == 404

def test_join_as_manager(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    _, _, manager_code = _create_shelter(client, owner_token)

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
    manager_token, _, _ = _create_shelter(client, token)
    res = client.post("/shelters/reset/volunteer", headers=_auth_headers(manager_token))
    assert res.status_code == 200


def test_reset_manager_code(client):
    token = _register_and_login(client)
    manager_token, _, _ = _create_shelter(client, token)
    res = client.post("/shelters/reset/manager", headers=_auth_headers(manager_token))
    assert res.status_code == 200


def test_reset_codes_requires_auth(client):
    assert client.post("/shelters/reset/volunteer").status_code == 401
    assert client.post("/shelters/reset/manager").status_code == 401


def test_volunteer_cannot_reset_codes(client):
    owner_token = _register_and_login(client, email="owner@example.com", name="Owner")
    _, volunteer_code, _ = _create_shelter(client, owner_token)

    volunteer_token = _register_and_login(client, email="vol@example.com", name="Vol")
    join_res = client.post(f"/shelters/join/volunteer/{volunteer_code}", headers=_auth_headers(volunteer_token))
    vol_token = join_res.json()["access_token"]

    assert client.post("/shelters/reset/volunteer", headers=_auth_headers(vol_token)).status_code == 403
    assert client.post("/shelters/reset/manager", headers=_auth_headers(vol_token)).status_code == 403

# endregion