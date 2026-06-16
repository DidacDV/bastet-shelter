import logging
from abc import ABC, abstractmethod

from fastapi import BackgroundTasks
from fastapi_mail import MessageSchema, MessageType

from app.core.email.email_config import fast_mail

logger = logging.getLogger(__name__)


class EmailSender(ABC):
    @abstractmethod
    def send(
        self,
        subject: str,
        recipients: list[str],
        body: str,
        background_tasks: BackgroundTasks,
        subtype: MessageType = MessageType.html,
    ) -> None:
        pass


class FastMailEmailSender(EmailSender):
    def send(
        self,
        subject: str,
        recipients: list[str],
        body: str,
        background_tasks: BackgroundTasks,
        subtype: MessageType = MessageType.html,
    ) -> None:
        message = MessageSchema(
            subject=subject,
            recipients=recipients,
            body=body,
            subtype=subtype,
        )
        background_tasks.add_task(fast_mail.send_message, message)


class LoggingEmailSenderDecorator(EmailSender):
    def __init__(self, wrapped: EmailSender):
        self._wrapped = wrapped

    def send(
        self,
        subject: str,
        recipients: list[str],
        body: str,
        background_tasks: BackgroundTasks,
        subtype: MessageType = MessageType.html,
    ) -> None:
        logger.info(
            "Queueing email | subject=%r recipients=%s",
            subject,
            recipients,
        )
        self._wrapped.send(
            subject=subject,
            recipients=recipients,
            body=body,
            background_tasks=background_tasks,
            subtype=subtype,
        )
