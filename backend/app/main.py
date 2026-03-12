from fastapi import FastAPI
from app.database import Base, engine
from fastapi.middleware.cors import CORSMiddleware

from app.routers.auth_router import router as auth_router
from app.routers.user_router import router as user_router
from app.routers.animal_router import router as animal_router
from app.routers.shelter_router import router as shelter_router

Base.metadata.create_all(bind=engine)
app = FastAPI(title="Bastet-Shelter")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(animal_router)
app.include_router(user_router)
app.include_router(shelter_router)
@app.get("/")
def root():
    return {"message": "bastet is running"}