from fastapi import Header

from app.localization import normalize_locale


def get_request_locale(accept_language: str | None = Header(default=None)) -> str:
    return normalize_locale(accept_language)
