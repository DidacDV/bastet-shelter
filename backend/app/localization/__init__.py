import json
from functools import lru_cache
from pathlib import Path

SUPPORTED_LOCALES = ("en", "ca", "es")
DEFAULT_LOCALE = "en"
_MESSAGES_DIR = Path(__file__).parent / "messages"


@lru_cache
def _load_locale(locale: str) -> dict[str, str]:
    file_path = _MESSAGES_DIR / f"{locale}.json"
    if not file_path.exists():
        return {}
    with file_path.open(encoding="utf-8") as file:
        return json.load(file)


def normalize_locale(language: str | None) -> str:
    if not language:
        return DEFAULT_LOCALE

    primary = language.split(",")[0].strip().lower().replace("_", "-")
    language_code = primary.split("-")[0]
    if language_code in SUPPORTED_LOCALES:
        return language_code
    return DEFAULT_LOCALE


def translate(key: str, locale: str = DEFAULT_LOCALE) -> str:
    normalized_locale = normalize_locale(locale)
    message = _load_locale(normalized_locale).get(key)
    if message is not None:
        return message

    if normalized_locale != DEFAULT_LOCALE:
        fallback = _load_locale(DEFAULT_LOCALE).get(key)
        if fallback is not None:
            return fallback

    return key
