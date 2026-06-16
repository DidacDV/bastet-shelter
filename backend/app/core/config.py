from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    DATABASE_URL: str
    GEOAPI_KEY: str
    ADMIN_AUTH_SECRET: str
    ADMIN_USERNAME: str
    ADMIN_PASSWORD: str
    AUTH_SECRET: str
    CLOUDINARY_CLOUD_NAME: str
    CLOUDINARY_API_KEY: str
    CLOUDINARY_API_SECRET: str
    ADOPTANT_SECRET: str
    MAIL_USERNAME: str
    MAIL_PASSWORD: str
    MAIL_FROM: str
    MAIL_PORT: int
    MAIL_SERVER: str
    FRONTEND_URL: str = "http://localhost:5173"
    PORTAL_BASE_URL: str = "http://localhost:5173"

    model_config = SettingsConfigDict(env_file=".env")

    @property
    def frontend_base_url(self) -> str:
        return self.FRONTEND_URL.rstrip("/")

settings = Settings()