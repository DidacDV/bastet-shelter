from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.core.utils import generate_code
from app.database import Base


class Shelter(Base):
    __tablename__ = "shelter"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    location = Column(String, nullable=False)
    volunteer_code = Column(String, nullable=False, unique=True, default=generate_code)
    manager_code = Column(String, nullable=False, unique=True, default=generate_code)

    refuges = relationship("Refuge", back_populates="shelter")
    tasks = relationship("Task", back_populates="shelter")