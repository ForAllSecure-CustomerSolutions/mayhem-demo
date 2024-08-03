from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "GPS Telemetry API"
    DEBUG: bool = True
    REDIS_HOST: str = "redis"
    REDIS_PORT: int = 6379


settings = Settings()
