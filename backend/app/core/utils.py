import re
import secrets
import unicodedata


def generate_code(length: int = 9) -> str:
    chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return ''.join(secrets.choice(chars) for _ in range(length))


def name_to_link_name(value: str) -> str:
    """Turn a display name into the URL-safe name used in adoption links."""
    normalized = unicodedata.normalize("NFKD", value)
    ascii_text = normalized.encode("ascii", "ignore").decode("ascii")
    link_name = re.sub(r"[^a-z0-9]+", "-", ascii_text.lower()).strip("-")
    return link_name or "item"


def generate_unique_link_name(base_name: str, is_taken) -> str:
    base_link_name = name_to_link_name(base_name)
    candidate = base_link_name
    suffix = 2
    while is_taken(candidate):
        candidate = f"{base_link_name}-{suffix}"
        suffix += 1
    return candidate