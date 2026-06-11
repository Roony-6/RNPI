from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import bcrypt
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.config import ALGORITHM, SECRET_KEY, TOKEN_MINUTES
from app.database import get_db
from app.models.catalogos import CatRol
from app.models.core import Personal

oauth2 = OAuth2PasswordBearer(tokenUrl="/auth/login")


def hash_password(plain: str) -> str:
    return bcrypt.hashpw(plain.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))
    except ValueError:
        return False


def crear_token(data: dict) -> str:
    payload = data.copy()
    payload["exp"] = datetime.now(timezone.utc) + timedelta(minutes=TOKEN_MINUTES)
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def usuario_actual(token: str = Depends(oauth2), db: Session = Depends(get_db)) -> Personal:
    credencial_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No autenticado o token expirado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload     = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        id_personal = int(payload.get("sub", 0))
    except (JWTError, ValueError):
        raise credencial_error

    usuario = db.get(Personal, id_personal)
    if not usuario or not usuario.activo:
        raise credencial_error
    return usuario


def solo_director(usuario: Personal = Depends(usuario_actual), db: Session = Depends(get_db)) -> Personal:
    rol    = db.get(CatRol, usuario.id_rol)
    nombre = rol.nombre_rol.lower() if rol else ""
    if not any(x in nombre for x in ("director", "coordinador")):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tiene permisos para realizar esta acción",
        )
    return usuario
