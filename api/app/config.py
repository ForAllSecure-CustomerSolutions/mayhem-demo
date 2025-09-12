from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "GPS Telemetry API"
    DEBUG: bool = True
    REDIS_HOST: str = "redis"
    REDIS_PORT: int = 6379
    MAX_LOCATIONS: int = 50  # Maximum number of locations to store (FIFO)


settings = Settings()
