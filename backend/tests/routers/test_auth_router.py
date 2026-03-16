def test_register(client):
    res = client.post("/auth/register", json={
        "name": "John",
        "last_name_1": "Doe",
        "email": "john@example.com",
        "password": "secret123",
    })
    assert res.status_code == 201
    assert "access_token" in res.json()

def test_register_duplicate_email(client):
    data = {"name": "John", "last_name_1": "Doe", "email": "john@example.com", "password": "secret123"}
    client.post("/auth/register", json=data)
    res = client.post("/auth/register", json=data)
    assert res.status_code == 409

def test_login(client):
    client.post("/auth/register", json={
        "name": "John", "last_name_1": "Doe",
        "email": "john@example.com", "password": "secret123"
    })
    res = client.post("/auth/login", data={
        "username": "john@example.com",
        "password": "secret123"
    })
    assert res.status_code == 200
    assert "access_token" in res.json()