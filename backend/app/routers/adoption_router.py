from fastapi import BackgroundTasks, status, Depends, APIRouter
from fastapi_mail import MessageSchema, MessageType
from sqlalchemy.orm import Session

from app.core.email import fast_mail
from app.database import get_db
from app.schemas.user_schema import UserCreate

router = APIRouter(prefix="/adoption", tags=["adoptions"])


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(
    request: UserCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    magic_link_url = "http://localhost:5173/test-link"

    message = MessageSchema(
        subject="Welcome to Bastet Shelter!", #
        recipients=[request.email],
        body=f"Hello {request.name}, click here to log in: {magic_link_url}",
        subtype=MessageType.html
    )

    background_tasks.add_task(fast_mail.send_message, message)

    return {"message": "Email sent! Go check your Mailtrap dashboard."}