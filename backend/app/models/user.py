from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base

class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    last_name_1 = Column(String, nullable=False)
    last_name_2 = Column(String, nullable=True)
    active = Column(Boolean, default=True)
    login_id = Column(Integer, ForeignKey("login.id"), unique=True)

    login = relationship("Login")