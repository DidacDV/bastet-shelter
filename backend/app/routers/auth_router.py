from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import verify_password, create_access_token, hash_password
from app.database import get_db
from app.models.login import Login
from app.models.shelter_member import ShelterMember
from app.models.user import User
from app.schemas.user_schema import LoginRequest, UserCreate
from app.schemas.auth_schema import TokenResponse
from fastapi.security import OAuth2PasswordRequestForm
router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(request: UserCreate, db: Session = Depends(get_db)):
    existing_login = db.query(Login).filter(Login.email == request.email).first()
    if existing_login:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists",
        )

    print(request.password)
    new_login = Login(
        email=request.email,
        password=hash_password(request.password),
    )
    db.add(new_login)
    db.flush()  #flush is needed to have the login id available

    new_user = User(
        name=request.name,
        last_name_1=request.last_name_1,
        last_name_2=request.last_name_2,
        active=True,
        login_id=new_login.id,
    )
    db.add(new_user)
    db.commit()

    access_token = create_access_token(data={"sub": new_login.email})
    return TokenResponse(access_token=access_token)

@router.post("/login", response_model=TokenResponse)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    login_record = db.query(Login).filter(Login.email == form_data.username).first()
    if not login_record:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if not verify_password(form_data.password, login_record.password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    user = db.query(User).filter(User.login_id == login_record.id).first()
    if not user or not user.active:
        raise HTTPException(status_code=403, detail="Account is inactive")

    member = db.query(ShelterMember).filter(ShelterMember.user_id == user.id).first()
    access_token = create_access_token(data={"sub": login_record.email, "role": member.role.value if member else None, "shelter_id": member.shelter_id if member else None})
    return TokenResponse(access_token=access_token)