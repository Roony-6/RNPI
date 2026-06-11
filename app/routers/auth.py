from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.auth.security import crear_token, verify_password
from app.database import get_db
from app.models.core import Personal
from app.schemas.personal import TokenRespuesta

router = APIRouter(prefix="/auth", tags=["Autenticación"])


@router.post("/login", response_model=TokenRespuesta)
def login(form: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    usuario = db.query(Personal).filter(Personal.correo == form.username).first()

    if not usuario or not verify_password(form.password, usuario.contrasena):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not usuario.activo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Su cuenta está inactiva. Contacte al administrador.",
        )

    token = crear_token({"sub": str(usuario.id_personal)})
    return {"access_token": token, "token_type": "bearer", "usuario": usuario}
