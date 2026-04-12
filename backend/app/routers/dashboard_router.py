from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.dependencies import require_volunteer
from app.database import get_db
from app.models.user import AuthenticatedUser
from app.schemas.dashboard_schema import ShelterDashboardResponse
from app.services.dashboard_service import DashboardService

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/", response_model=ShelterDashboardResponse)
def get_dashboard(
    db: Session = Depends(get_db),
    auth: AuthenticatedUser = Depends(require_volunteer),
):
    return DashboardService(db).get_dashboard(auth.shelter_id)