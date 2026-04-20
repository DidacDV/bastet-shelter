from sqlalchemy.orm import Session
from app.models.adoption.adoption_steps.magic_link_token import MagicLinkToken
from app.repositories.generic_repo import BaseRepository

class MagicLinkTokenRepository(BaseRepository[MagicLinkToken]):
    def __init__(self, db: Session):
        super().__init__(MagicLinkToken)
        self.db = db

    def get_by_token(self, db: Session, token: str) -> type[MagicLinkToken] | None:
        return db.query(MagicLinkToken).filter(MagicLinkToken.token == token).first()