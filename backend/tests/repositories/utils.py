from app.models.login import Login
from app.models.shelter import Shelter
from app.models.user import User


def _create_shelter(db, volunteer_code="VOL123", manager_code="MAN456") -> Shelter:
    shelter = Shelter(name="Rodamons", location="Barcelona",
                      volunteer_code=volunteer_code, manager_code=manager_code)
    db.add(shelter)
    db.commit()
    db.refresh(shelter)
    return shelter


def _create_user(db, email="user@example.com") -> User:
    login = Login(email=email, password="hashed")
    db.add(login)
    db.flush()
    user = User(name="John", last_name_1="Doe", active=True, login_id=login.id)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user