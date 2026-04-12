from tests.routers.test_shelter_router import _register_and_login, _auth_headers, _create_shelter

def test_delete_refuge_success(client):
    token = _register_and_login(client, email="owner@delete.com")
    new_token, _, _, _ = _create_shelter(client, token, name="Shelter Delete", refuge_name="Initial Refuge")
    
    res = client.get("/refuges/", headers=_auth_headers(new_token))
    assert res.status_code == 200
    refuges = res.json()
    assert len(refuges) == 1
    refuge_id = refuges[0]["id"]
    
    #refuge so we can delete it
    res = client.post("/refuges/", json={"name": "Second Refuge", "province_id": "08"}, headers=_auth_headers(new_token))
    assert res.status_code == 200
    second_refuge_id = res.json()["id"]
    
    res = client.delete(f"/refuges/{second_refuge_id}", headers=_auth_headers(new_token))
    assert res.status_code == 204
    
    res = client.get("/refuges/", headers=_auth_headers(new_token))
    assert len(res.json()) == 1

def test_delete_refuge_with_animals_fails(client):
    token = _register_and_login(client, email="owner_anim@delete.com")
    new_token, _, _, _ = _create_shelter(client, token, name="Shelter Animal Delete", refuge_name="Refuge with Animal")
    
    res = client.get("/refuges/", headers=_auth_headers(new_token))
    refuge_id = res.json()[0]["id"]
    
    client.post("/animals/", json={
        "name": "Catty",
        "birth_date": "2026-01-01",
        "description": "Lovely cat",
        "breed": "Common",
        "animal_type": "CAT",
        "refuge_id": refuge_id
    }, headers=_auth_headers(new_token))
    
    #try to delete refuge
    res = client.delete(f"/refuges/{refuge_id}", headers=_auth_headers(new_token))
    assert res.status_code == 400
    assert "move them out first" in res.json()["detail"]

def test_delete_refuge_with_shifts_fails(client):
    token = _register_and_login(client, email="owner_shift@delete.com")
    new_token, _, _, _ = _create_shelter(client, token, name="Shelter Shift Delete", refuge_name="Refuge with Shift")
    
    res = client.get("/refuges/", headers=_auth_headers(new_token))
    refuge_id = res.json()[0]["id"]
    
    client.post("/shifts/", params={"refuge_id": refuge_id}, json={
        "start_time": "2026-03-29T10:00:00",
        "end_time": "2026-03-29T14:00:00",
        "day": "2026-03-29"
    }, headers=_auth_headers(new_token))
    
    res = client.delete(f"/refuges/{refuge_id}", headers=_auth_headers(new_token))
    assert res.status_code == 400
    assert "shifts" in res.json()["detail"].lower() or "move them out first" in res.json()["detail"]

def test_delete_refuge_not_found(client):
    token = _register_and_login(client, email="owner_nf@delete.com")
    new_token, _, _, _ = _create_shelter(client, token)
    
    res = client.delete("/refuges/9999", headers=_auth_headers(new_token))
    assert res.status_code == 404

def test_delete_refuge_other_shelter(client):
    token1 = _register_and_login(client, email="owner1@delete.com")
    new_token1, _, _, _ = _create_shelter(client, token1, name="Shelter 1")
    res = client.get("/refuges/", headers=_auth_headers(new_token1))
    refuge_id_1 = res.json()[0]["id"]
    
    token2 = _register_and_login(client, email="owner2@delete.com")
    new_token2, _, _, _ = _create_shelter(client, token2, name="Shelter 2")
    
    res = client.delete(f"/refuges/{refuge_id_1}", headers=_auth_headers(new_token2))
    assert res.status_code == 404

def test_delete_last_refuge_fails(client):
    token = _register_and_login(client, email="owner_last@delete.com")
    new_token, _, _, _ = _create_shelter(client, token, name="Shelter Last Delete", refuge_name="The Only Refuge")
    
    res = client.get("/refuges/", headers=_auth_headers(new_token))
    refuge_id = res.json()[0]["id"]
    
    #try to delete the only refuge
    res = client.delete(f"/refuges/{refuge_id}", headers=_auth_headers(new_token))
    assert res.status_code == 400
    assert "last refuge" in res.json()["detail"].lower()
