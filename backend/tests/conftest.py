import os

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.database import Base, get_db

# Kept separate from DATABASE_URL on purpose: every test drops all tables.
TEST_DATABASE_URL = os.getenv("TEST_DATABASE_URL", "sqlite:///./test.db")

connect_args = {"check_same_thread": False} if TEST_DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(TEST_DATABASE_URL, connect_args=connect_args)
TestingSessionLocal = sessionmaker(bind=engine)


from app.models.province import Province

@pytest.fixture(autouse=True)
def db():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    
    # Add a mock province for testing
    mock_province = Province(id="08", name="Barcelona", community_code="09")
    session.add(mock_province)
    session.commit()

    def override_get_db():
        yield session

    app.dependency_overrides[get_db] = override_get_db
    yield session
    session.close()
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client():
    return TestClient(app)