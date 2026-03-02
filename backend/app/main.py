from fastapi import FastAPI
from app.database import Base, engine

Base.metadata.create_all(bind=engine)
app = FastAPI(title="Bastet-Shelter")
@app.get("/")
def root():
    return {"message": "bastet is running"}