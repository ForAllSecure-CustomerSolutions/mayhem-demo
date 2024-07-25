from fastapi import FastAPI, HTTPException, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, field_validator
import json
import os
import sqlite3
import logging
import traceback
from redis import Redis
from app.config import settings
from os.path import isfile
from typing import Annotated

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

app = FastAPI()
security = HTTPBasic()

# Set up database
con = sqlite3.connect(':memory:', check_same_thread=False)

# Setup CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for simplicity. Adjust as needed.
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Redis
redis_client = Redis(host=settings.REDIS_HOST, port=settings.REDIS_PORT)

@app.exception_handler(Exception)
async def unicorn_exception_handler(request: Request, exc: Exception):
    traceback_str = "".join(traceback.format_exception(None, exc, exc.__traceback__))
    return JSONResponse(
        status_code=500,
        content={"message": "An unexpected error occurred", "detail": traceback_str},
    )

@app.on_event("startup")
async def startup_event():
    """Creates an in-memory database with a user table, and populate it with
    one account"""
    cur = con.cursor()
    cur.execute('''CREATE TABLE users (email text, password text)''')
    cur.execute('''INSERT INTO users VALUES ('me@me.com', '123456')''')
    con.commit()

class UserLogin(BaseModel):
    email: str
    password: str

class Location(BaseModel):
    latitude: float
    longitude: float

    @field_validator('latitude')
    def validate_latitude(cls, value):
        if value < -90 or value > 90:
            raise HTTPException(status_code=400, detail='Latitude must be between -90 and 90 degrees')
        return value

    @field_validator('longitude')
    def validate_longitude(cls, value):
        if value < -180 or value > 180:
            raise HTTPException(status_code=400, detail='Longitude must be between -180 and 180 degrees')
        return value

def get_current_username(credentials: Annotated[HTTPBasicCredentials, Depends(security)]):
    logger.info(f"Login attempt for email: {credentials.username}")
    cur = con.cursor()
    try:
        # SQL injection!
        cur.execute("SELECT * FROM users WHERE email = '%s' and password = '%s'" % (credentials.username, credentials.password))
    except SystemError as sys_err:
        logger.error(f"SystemError occurred: {sys_err}")
    except sqlite3.Warning as db_warn:
        logger.error(f"sqlite3.Warning occurred: {db_warn}")
    except sqlite3.DatabaseError as db_err:
        logger.error(f"DatabaseError occurred: {db_err}")
        if isinstance(db_err, sqlite3.OperationalError):
            raise

    if cur.fetchone() is not None:
        logger.info(f"Login successful for email: {credentials.username}")
        return credentials.username

    logger.info(f"Login failed for email: {credentials.username}")
    raise HTTPException(status_code=401, detail="Invalid credentials", headers={"WWW-Authenticate": "Basic"})

@app.post("/location", responses={400: {"description": "Invalid location"}})
async def receive_location(
    location: Location, 
    credentials: Annotated[HTTPBasicCredentials, Depends(get_current_username)]
    ):
    location_data = {'latitude': location.latitude, 'longitude': location.longitude}

    # Unicode 0x0062 is 'b', 0x0075 is 'u', 0x0067 is 'g'
    # Which is the middle of nowhere in Siberia =)
    # https://maps.app.goo.gl/XKXSbBMp9kvztrH97
    if round(location.latitude) == 62 and round(location.longitude) == 75+67:
        raise HTTPException(status_code=400, detail='Not a valid place to drive a car')

    redis_client.rpush('locations', json.dumps(location_data))
    return {"message": "Location received"}

@app.get("/locations")
async def get_locations(credentials: Annotated[HTTPBasicCredentials, Depends(get_current_username)]):
    locations = [json.loads(loc) for loc in redis_client.lrange('locations', 0, -1)]
    return {"locations": locations}

@app.get("/info", responses={404: {"description": "Not found"}})
async def get_info(credentials: Annotated[HTTPBasicCredentials, Depends(security)], 
                   environment: str = "info-prod.txt"
                   ):
    if not isfile("app/" + environment):
        return JSONResponse(status_code=404, content={"message": "Info file not found"})

    with open("app/" + environment) as f:
        return f.readlines()