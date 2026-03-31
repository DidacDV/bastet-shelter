from sqladmin.authentication import AuthenticationBackend
from fastapi import Request

from app.core.config import settings

class AdminAuth(AuthenticationBackend):
    async def login(self, request: Request) -> bool:
        form = await request.form()
        username, password = form["username"], form["password"]

        if username == settings.ADMIN_USERNAME and password == settings.ADMIN_PASSWORD:
            request.session.update({"token": "admin_authenticated"})
            return True

        return False

    async def logout(self, request: Request) -> bool:
        request.session.clear()
        return True

    async def authenticate(self, request: Request) -> bool:
        token = request.session.get("token")
        return token == "admin_authenticated"

authentication_backend = AdminAuth(secret_key=settings.ADMIN_AUTH_SECRET)