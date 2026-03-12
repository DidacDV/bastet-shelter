from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.security import decode_access_token
from app.database import get_db
from app.models.login import Login
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

    return AuthenticatedUser(user = user, role =  role)

def require_role(*roles: str):
    def checker(auth: AuthenticatedUser = Depends(get_current_user)):
        if auth.role not in roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return auth
    return checker

require_manager = require_role("MANAGER", "ADMIN")
require_volunteer = require_role("VOLUNTEER", "MANAGER", "ADMIN")
require_admin = require_role("ADMIN")