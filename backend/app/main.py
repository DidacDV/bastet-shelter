import logging
from fastapi import FastAPI
from contextlib import asynccontextmanager

from sqladmin import Admin
from app.admin.admin_views import ShelterAdmin, RefugeAdmin, LoginAdmin, UserAdmin, ShelterMemberAdmin, AnimalAdmin, \
    ProvinceAdmin, TraitAdmin
from app.admin.admin_auth import authentication_backend

from app.database import Base, engine, SessionLocal
from fastapi.middleware.cors import CORSMiddleware

from app.routers.dashboard_router import router as dashboard_router
from app.routers.auth_router import router as auth_router
from app.routers.user_router import router as user_router
from app.routers.animal_router import router as animal_router
from app.routers.shelter_router import router as shelter_router
from app.routers.refuge_router import router as refuge_router
from app.routers.task_router import router as task_router
from app.routers.shift_router import router as shift_router
from app.routers.geo_router import router as geo_router
from app.routers.trait_router import router as trait_router

from app.services.geo_service import GeoService
import app.models as models

Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    db = SessionLocal()
    try:
        await GeoService.run_periodic_update(db)
    finally:
        db.close()
    yield

logging.basicConfig(level=logging.INFO)
app = FastAPI(title="Bastet-Shelter", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# routers
app.include_router(auth_router)
app.include_router(animal_router)
app.include_router(user_router)
app.include_router(shelter_router)
app.include_router(refuge_router)
app.include_router(task_router)
app.include_router(shift_router)
app.include_router(geo_router)
app.include_router(dashboard_router)
app.include_router(trait_router)

# create SQLAdmin page
admin = Admin(app, engine, authentication_backend=authentication_backend)

# load views to SQLAdmin
admin.add_view(ShelterAdmin)
admin.add_view(RefugeAdmin)
admin.add_view(RefugeAdmin)
admin.add_view(LoginAdmin)
admin.add_view(UserAdmin)
admin.add_view(ShelterMemberAdmin)
admin.add_view(AnimalAdmin)
admin.add_view(ProvinceAdmin)
admin.add_view(TraitAdmin)
@app.get("/")
def root():
    return {"message": "bastet is running"}