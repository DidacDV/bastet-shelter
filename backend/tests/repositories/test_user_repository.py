from app.repositories.user_repo import UserRepository
from app.models.user import User
from tests.repositories.utils import _create_user


class TestUserRepository:
    repo = UserRepository()

    def test_init(self):
        repo = UserRepository()
        assert repo.model == User

    def test_get_by_email(self, db):
        _create_user(db, email="find@example.com")
        result = self.repo.get_by_email(db, "find@example.com")
        assert result is not None
        assert result.name == "John"

    def test_get_by_email_not_found(self, db):
        result = self.repo.get_by_email(db, "nobody@example.com")
        assert result is None

    def test_get_by_email_returns_correct_user(self, db):
        _create_user(db, email="alice@example.com")
        _create_user(db, email="bob@example.com")

        result = self.repo.get_by_email(db, "alice@example.com")

        assert result.name == "John"  # both are "John" but only alice's record
        # verify we got the right login attached
        assert result.login.email == "alice@example.com"