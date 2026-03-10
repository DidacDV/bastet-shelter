from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.user import User
from app.repositories.user_repo import UserRepository
from app.schemas.user_schema import UserResponse
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["users"])

def get_user_service(db: Session = Depends(get_db)) -> UserService:
    return UserService(UserRepository(), db)

@router.get("/me")
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    return {
        "id": current_user.id,
        "name": current_user.name,
        "last_name_1": current_user.last_name_1,
        "last_name_2": current_user.last_name_2,
        "email": current_user.login.email,
    }

@router.get("/{email}", response_model=UserResponse)
def get_user_by_email(email: str, service: UserService = Depends(get_user_service)):
    try:
        return service.get_user(email)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))