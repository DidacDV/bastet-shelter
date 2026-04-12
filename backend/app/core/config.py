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

    model_config = SettingsConfigDict(env_file=".env")

settings = Settings()