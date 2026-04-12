from sqlalchemy.orm import Session

from app.models.login import Login
from app.models.user import User
from app.repositories.generic_repo import BaseRepository


# noinspection PyMethodMayBeStatic
class UserRepository(BaseRepository[User]):
    def __init__(self):
        super().__init__(User)

    def get_by_email(self, db: Session, email: str) -> User | None:
        return db.query(User).join(Login).filter(Login.email == email).first()

user_repo = UserRepository()