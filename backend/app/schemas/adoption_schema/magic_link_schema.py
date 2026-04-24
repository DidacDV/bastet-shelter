from pydantic import BaseModel, EmailStr

class MagicLinkRequest(BaseModel):
    email: EmailStr
    name: str

class AdoptantTokenResponse(BaseModel):
    access_token: str
    token_type: str
    adoptant_name: str