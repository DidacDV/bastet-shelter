from sqlalchemy import Column, Integer, String
from app.database import Base

class Login(Base):
    __tablename__ = "login"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, nullable=False, index=True)
    password = Column(String, nullable=False)
