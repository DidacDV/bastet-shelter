from sqlalchemy import Column, String, DateTime, func
from app.database import Base


class Province(Base):
    __tablename__ = "provinces"
    
    id = Column(String, primary_key=True, index=True) #CPRO from esp geo api
    name = Column(String, unique=True, index=True)
    community_code = Column(String) #CCOM --> 09 for Catalonia
    last_updated = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )