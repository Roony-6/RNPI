import os

from dotenv import load_dotenv

load_dotenv()

DATABASE_URL  = os.getenv("DATABASE_URL", "postgresql://postgres:1234@localhost:5432/rnpi")
SECRET_KEY    = os.getenv("SECRET_KEY", "cambia-esta-clave-secreta-en-produccion")
ALGORITHM     = "HS256"
TOKEN_MINUTES = int(os.getenv("TOKEN_EXPIRE_MINUTES", "480"))
