import secrets

def generate_code(length: int = 9) -> str:
    chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return ''.join(secrets.choice(chars) for _ in range(length))