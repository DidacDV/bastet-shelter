def _register_and_login(client):
    client.post("/auth/register", json={
        "name": "Jane",
        "last_name_1": "Doe",
        "email": "jane@example.com",
        "password": "secret123",
    })
    res = client.post("/auth/login", data={
        "username": "jane@example.com",
        "password": "secret123",
    })
    return res.json()["access_token"]


def test_get_me(client):
    token = _register_and_login(client)
    res = client.get("/users/me", headers={"Authorization": f"Bearer {token}"})
    assert res.status_code == 200
    data = res.json()
    assert data["email"] == "jane@example.com"


def test_get_me_unauthenticated(client):
    res = client.get("/users/me")
    assert res.status_code == 401
