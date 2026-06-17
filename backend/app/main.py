import logging

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from fastapi import FastAPI
from contextlib import asynccontextmanager

from sqladmin import Admin
from starlette import status
from starlette.requests import Request
from starlette.responses import JSONResponse

from app.admin.admin_views import ShelterAdmin, RefugeAdmin, LoginAdmin, UserAdmin, ShelterMemberAdmin, AnimalAdmin, \
    ProvinceAdmin, TraitAdmin
from app.admin.admin_auth import authentication_backend
from app.core.exceptions import NotFoundError, BusinessLogicError, AuthorizationError

from app.database import Base, engine, SessionLocal
from fastapi.middleware.cors import CORSMiddleware

from app.jobs.treatment_reset_job import reset_treatments
from app.routers.adoption_process_router import router as adoption_process_router
from app.routers.adoption_steps_router import router as adoption_steps_router
from app.routers.adoption_auth_router import router as adoption_auth_router
from app.routers.adoptant_router import router as adoptant_router
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
from app.routers.medical_router import router as medical_router
from app.routers.advertisement_router import router as advertisement_router

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

    scheduler = AsyncIOScheduler()
    scheduler.add_job(reset_treatments, "interval", hours=1)
    scheduler.start()

    yield

logging.basicConfig(level=logging.INFO)
app = FastAPI(title="Bastet-Shelter", lifespan=lifespan)

@app.exception_handler(NotFoundError)
async def not_found_handler(request: Request, exc: NotFoundError):
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={"detail": exc.message},
    )

@app.exception_handler(BusinessLogicError)
async def business_logic_handler(request: Request, exc: BusinessLogicError):
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content={"detail": exc.message},
    )

@app.exception_handler(AuthorizationError)
async def auth_error_handler(request: Request, exc: AuthorizationError):
    return JSONResponse(
        status_code=status.HTTP_403_FORBIDDEN,
        content={"detail": exc.message},
    )


@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    error_msg = str(exc).lower()
    if "not found" in error_msg or "invalid code" in error_msg or "code not found" in error_msg:
        status_code = 404
    else:
        status_code = 400

    return JSONResponse(
        status_code=status_code,
        content={"detail": str(exc)},
    )

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
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
app.include_router(medical_router)
app.include_router(adoption_steps_router)
app.include_router(adoption_process_router)
app.include_router(adoption_auth_router)
app.include_router(adoptant_router)
app.include_router(advertisement_router)

# create SQLAdmin page
admin = Admin(app, engine, authentication_backend=authentication_backend)

# load views to SQLAdmin
admin.add_view(ShelterAdmin)
admin.add_view(RefugeAdmin)
admin.add_view(LoginAdmin)
admin.add_view(UserAdmin)
admin.add_view(ShelterMemberAdmin)
admin.add_view(AnimalAdmin)
admin.add_view(ProvinceAdmin)
admin.add_view(TraitAdmin)


@app.api_route("/", methods=["GET", "HEAD"])
def root():
    return {"message": "bastet is running"}
