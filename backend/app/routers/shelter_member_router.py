from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user, require_role, require_volunteer
from app.database import get_db
from app.models.user import User, AuthenticatedUser
from app.schemas.shelter_member_schema import ShelterMemberResponse, ShelterMemberInfo
from app.services.shelter_member_service import ShelterMemberService

router = APIRouter(prefix="/shelter-members", tags=["shelter-members"])


def get_shelter_member_service(db: Session = Depends(get_db)) -> ShelterMemberService:
    return ShelterMemberService(db)


@router.post("/join/{shelter_code}", response_model=ShelterMemberResponse, status_code=status.HTTP_201_CREATED)
def join_shelter(shelter_code: str, service: ShelterMemberService = Depends(get_shelter_member_service), auth: AuthenticatedUser = Depends(require_volunteer),
    db: Session = Depends(get_db),
):
    try:
        return service.create_volunteer_member(auth.user.id, shelter_code)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/me", response_model=ShelterMemberInfo)
def get_my_membership(service: ShelterMemberService = Depends(get_shelter_member_service), auth: AuthenticatedUser = Depends(require_volunteer)):
    member = service.get_by_user(auth.user.id)
    if not member:
        raise HTTPException(status_code=404, detail="You are not a member of any shelter")
    return member