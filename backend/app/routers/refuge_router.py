from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_db, get_current_user, require_manager
from app.models.user import AuthenticatedUser
from app.schemas.refuge_schema import RefugeCreate, RefugeResponse, RefugeUpdate
from app.services.refuge_service import RefugeService

router = APIRouter(prefix="/refuges", tags=["refuges"])

def get_refuge_service(db: Session = Depends(get_db)) -> RefugeService:
    return RefugeService(db)


@router.post("/", response_model=RefugeResponse)
def create_refuge(
    data: RefugeCreate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: RefugeService = Depends(get_refuge_service)
):
    return service.create_refuge(data, auth.shelter_id)

@router.get("/", response_model=List[RefugeResponse])
def get_refuges(
    auth: AuthenticatedUser = Depends(get_current_user),
    service: RefugeService = Depends(get_refuge_service)
):
    return service.get_refuges(auth.shelter_id)

@router.delete("/{refuge_id}", status_code=204)
def delete_refuge(
    refuge_id: int,
    auth: AuthenticatedUser = Depends(require_manager),
    service: RefugeService = Depends(get_refuge_service)
):
    service.delete_refuge(refuge_id, auth.shelter_id)

@router.put("/{refuge_id}", response_model=RefugeResponse)
def update_refuge(
    refuge_id: int,
    data: RefugeUpdate,
    auth: AuthenticatedUser = Depends(require_manager),
    service: RefugeService = Depends(get_refuge_service)
):
    return service.update_refuge(refuge_id, auth.shelter_id, data)
