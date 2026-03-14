import secrets

from sqlalchemy import Column, Integer, String

from app.database import Base

def generate_code(length: int = 9) -> str:
    chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return ''.join(secrets.choice(chars) for _ in range(length))

class Shelter(Base):
    __tablename__ = "shelter"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    location = Column(String, nullable=False)
    volunteer_code = Column(String, nullable=False, unique=True, default=generate_code)
    manager_code = Column(String, nullable=False, unique=True, default=generate_code)