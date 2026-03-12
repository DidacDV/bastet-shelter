from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user, require_manager
from app.database import get_db
from app.models.user import User, AuthenticatedUser
from app.repositories.shelter_repo import ShelterRepository
from app.schemas.shelter_schema import ShelterResponse, ShelterCreate
from app.services.shelter_service import ShelterService

router = APIRouter(prefix="/shelters", tags=["shelters"])

def get_shelter_service(db: Session = Depends(get_db)) -> ShelterService:
    return ShelterService(ShelterRepository(), db)

@router.post("/", response_model=ShelterResponse, status_code=201)
def create_shelter(data: ShelterCreate, service: ShelterService = Depends(get_shelter_service), auth: AuthenticatedUser = Depends(require_manager)):
    return service.create_shelter(data, auth.user.id)

@router.get("/{code}", response_model=ShelterResponse)
def get_shelter_by_code(code: str, service: ShelterService = Depends(get_shelter_service)):
    try:
        return service.get_shelter(code)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))