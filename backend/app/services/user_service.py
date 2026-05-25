from sqlalchemy.orm import Session

from app.models.shelter_member import ShelterMember
from app.models.shift.shift_participant import ShiftParticipant
from app.models.task.shift_task import ShiftTask
from app.models.user import User
from app.repositories.user_repo import UserRepository
from app.core.exceptions import NotFoundError


class UserService:
    def __init__(self, repository: UserRepository, db: Session):
        self.repository = repository
        self.db = db

    def get_user(self, email: str) -> User:
        user = self.repository.get_by_email(self.db, email)
        if not user:
            raise NotFoundError(f"User with email {email} not found")
        return user

    def delete_user(self, user_id: int) -> None:
        user = self.repository.get_by_id(self.db, user_id)
        if not user:
            raise NotFoundError("User not found")

        #find member associated
        member = (
            self.db.query(ShelterMember)
            .filter(ShelterMember.user_id == user_id)
            .first()
        )

        if member:
            #find shift participants associated to member
            participants = (
                self.db.query(ShiftParticipant)
                .filter(ShiftParticipant.member_id == member.id)
                .all()
            )

            for participant in participants:
                #nullify participant on its shift tasks
                self.db.query(ShiftTask).filter(
                    ShiftTask.participant_id == participant.id
                ).update({"participant_id": None})
                self.db.delete(participant)

            self.db.delete(member)

        if user.login:
            self.db.delete(user.login)

        self.db.delete(user)
        self.db.commit()