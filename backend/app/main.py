from fastapi import FastAPI
from app.database import Base, engine
from fastapi.middleware.cors import CORSMiddleware

from app.routers.dashboard_router import router as dashboard_router
from app.routers.auth_router import router as auth_router
from app.routers.user_router import router as user_router
from app.routers.animal_router import router as animal_router
from app.routers.shelter_router import router as shelter_router
from app.routers.refuge_router import router as refuge_router
from app.routers.task_router import router as task_router
from app.routers.shift_router import router as shift_router

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
app.include_router(refuge_router)
app.include_router(task_router)
app.include_router(shift_router)
app.include_router(dashboard_router)
@app.get("/")
def root():
    return {"message": "bastet is running"}