import secrets
from datetime import datetime, timedelta, timezone

from fastapi import BackgroundTasks
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.email.email_sender import send_email
from app.core.email.templates import magic_link_email
from app.core.exceptions import AuthorizationError
from app.core.security import create_access_token
from app.models.adoption.adoptant import Adoptant
from app.models.adoption.adoption_steps.magic_link_token import MagicLinkToken
from app.repositories.adoption.adoptant_repo import AdoptantRepository
from app.repositories.magic_link_repo import MagicLinkTokenRepository
from app.schemas.adoption_schema.magic_link_schema import MagicLinkRequest, AdoptantTokenResponse

class AdoptantAuthService:
    def __init__(self, db: Session):
        self.db = db
        self.adoptant_repo = AdoptantRepository(db)
        self.token_repo = MagicLinkTokenRepository(db)

    def request_magic_link(self, data: MagicLinkRequest, background_tasks: BackgroundTasks) -> dict:
        adoptant = self.adoptant_repo.get_by_email(self.db, data.email)
        if not adoptant:
            adoptant = Adoptant(email=data.email, name=data.name)
            self.adoptant_repo.create(self.db, adoptant)
        elif adoptant.name != data.name:
            adoptant.name = data.name
            self.db.commit()

        raw_token = secrets.token_urlsafe(32)
        expires_at = datetime.now(timezone.utc) + timedelta(days=30)

        magic_link = MagicLinkToken(
            adoptant_id=int(adoptant.id),
            token=raw_token,
            expires_at=expires_at.replace(tzinfo=None),
        )
        self.token_repo.create(self.db, magic_link)

        frontend_magic_link_url = f"{settings.frontend_base_url}/verify?token={raw_token}"

        send_email(
            subject="Your access link to Bastet Shelter",
            recipients=[str(adoptant.email)],
            body=magic_link_email(name=str(adoptant.name), magic_link_url=frontend_magic_link_url),
            background_tasks=background_tasks,
        )

        return {"message": "If the details are correct, a magic link has been sent to your email."}

    def verify_magic_link(self, token: str) -> AdoptantTokenResponse:
        magic_link = self.token_repo.get_by_token(self.db, token)

        if not magic_link:
            raise AuthorizationError("Invalid token")

        if magic_link.expires_at < datetime.now(timezone.utc).replace(tzinfo=None):
            raise AuthorizationError("Token has expired. Please request a new one.")

        jwt_payload = {
            "sub": magic_link.adoptant.email,
            "role": "adoptant",
            "adoptant_id": magic_link.adoptant.id
        }

        session_duration = timedelta(days=30)
        access_token = create_access_token(data=jwt_payload, expires_delta=session_duration)

        return AdoptantTokenResponse(
            access_token=access_token,
            token_type="bearer",
            adoptant_name=magic_link.adoptant.name
        )