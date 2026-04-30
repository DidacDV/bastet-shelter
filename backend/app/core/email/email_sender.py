from fastapi import BackgroundTasks
from fastapi_mail import MessageType, MessageSchema
from pydantic import NameEmail

from app.core.email.email_config import fast_mail


def send_email(
    subject: str,
    recipients: list[str],
    body: str,
    background_tasks: BackgroundTasks,
    subtype: MessageType = MessageType.html
):
    message = MessageSchema(
        subject=subject,
        recipients=recipients,
        body=body,
        subtype=subtype
    )
    background_tasks.add_task(fast_mail.send_message, message)