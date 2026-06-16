from fastapi import BackgroundTasks
from fastapi_mail import MessageType

from app.core.email.email_senders import (
    EmailSender,
    FastMailEmailSender,
    LoggingEmailSenderDecorator,
)

_default_email_sender: EmailSender = LoggingEmailSenderDecorator(FastMailEmailSender())


def send_email(
    subject: str,
    recipients: list[str],
    body: str,
    background_tasks: BackgroundTasks,
    subtype: MessageType = MessageType.html,
):
    _default_email_sender.send(
        subject=subject,
        recipients=recipients,
        body=body,
        background_tasks=background_tasks,
        subtype=subtype,
    )
