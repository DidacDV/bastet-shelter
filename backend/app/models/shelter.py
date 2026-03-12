import random

from sqlalchemy import Column, Integer, String

from app.database import Base

def generate_codi(length: int = 9) -> str:
    chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return ''.join(random.choices(chars, k=length))

class Shelter(Base):
    __tablename__ = "shelter"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    location = Column(String, nullable=False)
    code = Column(String, nullable=False, unique=True, default=generate_codi)