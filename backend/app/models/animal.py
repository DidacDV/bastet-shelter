from sqlalchemy import Column, Integer, String, Boolean
from app.database import Base

class Animal(Base):
    __tablename__ = "animal"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)