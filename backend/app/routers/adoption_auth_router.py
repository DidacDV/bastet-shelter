from fastapi import APIRouter, Depends, status, BackgroundTasks
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.adoption_schema.magic_link_schema import MagicLinkRequest, AdoptantTokenResponse
from app.services.adoptant_auth_service import AdoptantAuthService

router = APIRouter(prefix="/adoption-auth", tags=["Adoption Login"])

# used when user requests a link for the first time in the adoption_schema portal
@router.post("/request-access", status_code=status.HTTP_200_OK)
def request_magic_link(
        data: MagicLinkRequest,
        background_tasks: BackgroundTasks,
        db: Session = Depends(get_db)
):
    service = AdoptantAuthService(db)
    return service.request_magic_link(data, background_tasks)

# used when user clicks the link received through request access to get the adoptant JWT token
@router.get("/verify", response_model=AdoptantTokenResponse)
def verify_magic_link(token: str, db: Session = Depends(get_db)):
    service = AdoptantAuthService(db)
    return service.verify_magic_link(token)