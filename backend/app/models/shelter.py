from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship, Mapped, mapped_column
from app.core.utils import generate_code
from app.database import Base


class Shelter(Base):
    __tablename__ = "shelter"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    province_id: Mapped[str] = mapped_column(ForeignKey("provinces.id"), nullable=False)
    volunteer_code: Mapped[str] = mapped_column(String, nullable=False, unique=True, default=generate_code)
    manager_code: Mapped[str] = mapped_column(String, nullable=False, unique=True, default=generate_code)

    province = relationship("Province")
    refuges = relationship("Refuge", back_populates="shelter")
    tasks = relationship("Task", back_populates="shelter")