from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_current_user, require_shelter_manager, require_shelter_volunteer
from app.database import get_db
from app.models.shelter_member import RoleEnum
from app.models.user import AuthenticatedUser
from app.schemas.shelter_member_schema import ShelterMemberInfo
from app.schemas.shelter_schema import ShelterResponse, ShelterCreate, ShelterWithTokenResponse, ShelterUpdate
from app.services.shelter_service import ShelterService

router = APIRouter(prefix="/shelters", tags=["shelters"])

def get_shelter_service(db: Session = Depends(get_db)) -> ShelterService:
    return ShelterService(db)

@router.post("/", response_model=ShelterWithTokenResponse, status_code=status.HTTP_201_CREATED)
def create_shelter(
    data: ShelterCreate,
    service: ShelterService = Depends(get_shelter_service),
    auth: AuthenticatedUser = Depends(get_current_user)
):
    return service.create_shelter(data, auth.user.id, auth.user.login.email)

@router.put("/", response_model=ShelterResponse, status_code=status.HTTP_200_OK)
def update_shelter(
        data: ShelterUpdate,
        service: ShelterService = Depends(get_shelter_service),
        auth: AuthenticatedUser = Depends(require_shelter_manager)
):
    return service.update_shelter(auth.shelter_id, data)

@router.get("/info", status_code=status.HTTP_200_OK)
def get_shelter_basic_info(
        service: ShelterService = Depends(get_shelter_service),
        auth: AuthenticatedUser = Depends(require_shelter_volunteer)
):
    if auth.role == RoleEnum.MANAGER:
        return service.get_shelter_by_id(auth.shelter_id)
    return service.get_shelter_basic_info_by_id(auth.shelter_id)

@router.get("/me", response_model=ShelterMemberInfo)
def get_my_membership(
    service: ShelterService = Depends(get_shelter_service),
    auth: AuthenticatedUser = Depends(get_current_user),
):
    member = service.get_by_user(auth.user.id)
    if not member:
        raise HTTPException(status_code=404, detail="You are not a member of any shelter")
    return member

@router.post("/join/volunteer/{code}", status_code=status.HTTP_201_CREATED)
def join_as_volunteer(
        code: str,
        service: ShelterService = Depends(get_shelter_service),
        auth: AuthenticatedUser = Depends(get_current_user),
):
    return service.join_as_volunteer(auth.user.id, code, auth.user.login.email)

@router.post("/join/manager/{code}", status_code=status.HTTP_201_CREATED)
def join_as_manager(
        code: str,
        service: ShelterService = Depends(get_shelter_service),
        auth: AuthenticatedUser = Depends(get_current_user),
):
    return service.join_as_manager(auth.user.id, code, auth.user.login.email)

@router.post("/reset/volunteer", status_code=status.HTTP_200_OK)
def reset_volunteer_code(
        service: ShelterService = Depends(get_shelter_service),
        auth: AuthenticatedUser = Depends(require_shelter_manager),
):
    return {"code": service.reset_volunteer_code(auth.shelter_id)}

@router.post("/reset/manager", status_code=status.HTTP_200_OK)
def reset_manager_code(
        service: ShelterService = Depends(get_shelter_service),
        auth: AuthenticatedUser = Depends(require_shelter_manager),
):
    return {"code": service.reset_manager_code(auth.shelter_id)}