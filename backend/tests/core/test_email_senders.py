from unittest.mock import MagicMock, patch

from fastapi import BackgroundTasks
from fastapi_mail import MessageType

from app.core.email.email_senders import (
    FastMailEmailSender,
    LoggingEmailSenderDecorator,
)


def test_logging_decorator_delegates_to_wrapped_sender():
    wrapped = MagicMock()
    decorator = LoggingEmailSenderDecorator(wrapped)
    background_tasks = BackgroundTasks()

    decorator.send(
        subject="Test subject",
        recipients=["user@example.com"],
        body="<p>Hello</p>",
        background_tasks=background_tasks,
    )

    wrapped.send.assert_called_once_with(
        subject="Test subject",
        recipients=["user@example.com"],
        body="<p>Hello</p>",
        background_tasks=background_tasks,
        subtype=MessageType.html,
    )


@patch("app.core.email.email_senders.fast_mail")
def test_fast_mail_sender_queues_background_task(mock_fast_mail):
    sender = FastMailEmailSender()
    background_tasks = MagicMock()

    sender.send(
        subject="Adoption update",
        recipients=["adoptant@example.com"],
        body="<p>Update</p>",
        background_tasks=background_tasks,
        subtype=MessageType.html,
    )

    background_tasks.add_task.assert_called_once()
    assert background_tasks.add_task.call_args[0][0] == mock_fast_mail.send_message
    message = background_tasks.add_task.call_args[0][1]
    assert message.subject == "Adoption update"
    assert message.recipients[0].email == "adoptant@example.com"
    assert message.body == "<p>Update</p>"
