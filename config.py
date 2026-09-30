import os

from dotenv import load_dotenv

# Load settings from a local .env file (never committed - see .env.example)
load_dotenv()


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "change-me")

    DB_CONFIG = {
        "host": os.getenv("DB_HOST", "localhost"),
        "user": os.getenv("DB_USER", "root"),
        "password": os.getenv("DB_PASSWORD", ""),
        "database": os.getenv("DB_NAME", "gojo"),
    }

    # Gmail account + App Password used for OTP / account emails
    EMAIL_USER = os.getenv("EMAIL_USER", "")
    EMAIL_PASS = os.getenv("EMAIL_PASS", "")
