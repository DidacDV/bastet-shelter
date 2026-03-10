from sqlalchemy.orm import Session
from app.models.user import User
from app.repositories.user_repo import UserRepository


class UserService:
    def __init__(self, repository: UserRepository, db: Session):
        self.repository = repository
        self.db = db

    def get_user(self, email: str) -> User:
        user = self.repository.get_by_email(self.db, email)
        if not user:
            raise ValueError(f"User with email {email} not found")
        return user