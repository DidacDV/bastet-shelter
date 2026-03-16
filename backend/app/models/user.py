from typing import Optional

from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from dataclasses import dataclass

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


@dataclass
class AuthenticatedUser:
    user: User
    role: Optional[str]
    shelter_id: Optional[int] = None