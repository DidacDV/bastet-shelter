from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies.role_dependencies import get_current_user
from app.database import get_db
from app.models.user import AuthenticatedUser
from app.repositories.user_repo import UserRepository
from app.schemas.user_schema import UserResponse
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["users"])

def get_user_service(db: Session = Depends(get_db)) -> UserService:
    return UserService(UserRepository(), db)

@router.get("/me")
def get_current_user_profile(auth: AuthenticatedUser = Depends(get_current_user),):
    user = auth.user
    return {
        "id": user.id,
        "name": user.name,
        "last_name_1": user.last_name_1,
        "last_name_2": user.last_name_2,
        "email": user.login.email,
    }

@router.get("/{email}", response_model=UserResponse)
def get_user_by_email(email: str, service: UserService = Depends(get_user_service)):
    try:
        return service.get_user(email)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))