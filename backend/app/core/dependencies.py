from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.security import decode_access_token
from app.database import get_db
from app.models.login import Login
from app.models.shelter import Shelter
from app.models.shelter_member import ShelterMember, RoleEnum
from app.models.user import User, AuthenticatedUser

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> AuthenticatedUser:
    payload = decode_access_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    email: str = payload.get("sub")
    if email is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
        )

    role: str = payload.get("role")
    user = db.query(User).join(Login).filter(Login.email == email).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    if not user.active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive user",
        )

    return AuthenticatedUser(user = user, role =  role, shelter_id = payload.get("shelter_id"))

def require_role(*roles: str):
    def checker(auth: AuthenticatedUser = Depends(get_current_user)):
        if auth.role not in roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return auth
    return checker

def require_shelter_manager(
    auth: AuthenticatedUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AuthenticatedUser:
    """Checks that the current user is a MANAGER OR ADMIN of the specific shelter identified by code."""
    if auth.role not in ("MANAGER", "ADMIN"):
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    if not auth.shelter_id:
        raise HTTPException(status_code=403, detail="Not a member of any shelter")

    member = db.query(ShelterMember).filter(
        ShelterMember.user_id == auth.user.id,
        ShelterMember.shelter_id == auth.shelter_id
    ).first()
    if not member or member.role not in (RoleEnum.MANAGER, RoleEnum.ADMIN):
        raise HTTPException(status_code=403, detail="Not a manager of this shelter")
    return auth

def require_shelter_volunteer(
    auth: AuthenticatedUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AuthenticatedUser:
    """Checks that the current user is a MANAGER OR ADMIN of the specific shelter identified by code."""
    if auth.role not in ("VOLUNTEER", "MANAGER", "ADMIN"):
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    if not auth.shelter_id:
        raise HTTPException(status_code=403, detail="Not a member of any shelter")

    member = db.query(ShelterMember).filter(
        ShelterMember.user_id == auth.user.id,
        ShelterMember.shelter_id == auth.shelter_id
    ).first()
    if not member or member.role not in (RoleEnum.VOLUNTEER, RoleEnum.MANAGER, RoleEnum.ADMIN):
        raise HTTPException(status_code=403, detail="Not a member of this shelter")
    return auth


require_manager = require_role("MANAGER", "ADMIN")
require_volunteer = require_role("VOLUNTEER", "MANAGER", "ADMIN")
require_admin = require_role("ADMIN")