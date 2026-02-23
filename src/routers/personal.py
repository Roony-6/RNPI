from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.database import get_db
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext
from sqlalchemy import text

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class PersonalCreate(BaseModel):
    nombre_completo: str
    rfc: str
    curp: str
    correo: EmailStr
    contrasena: str
    id_rol: int

@router.get("/")
def listar_personal(db: Session = Depends(get_db)):
    resultado = db.execute(text("SELECT id_personal, nombre_completo, rfc, curp, correo, activo, id_rol FROM personal")).fetchall()
    return [dict(r._mapping) for r in resultado]

@router.get("/{id_personal}")
def obtener_personal(id_personal: int, db: Session = Depends(get_db)):
    resultado = db.execute(text(
        "SELECT id_personal, nombre_completo, rfc, curp, correo, activo, id_rol FROM personal WHERE id_personal = :id",
        {"id": id_personal})
    ).fetchone()
    if not resultado:
        raise HTTPException(status_code=404, detail="Personal no encontrado")
    return dict(resultado._mapping)

@router.post("/", status_code=201)
def registrar_personal(p: PersonalCreate, db: Session = Depends(get_db)):
    hash_pass = pwd_context.hash(p.contrasena)
    db.execute(
        """INSERT INTO personal (nombre_completo, rfc, curp, correo, contrasena, id_rol)
           VALUES (:nombre, :rfc, :curp, :correo, :contrasena, :rol)""",
        {"nombre": p.nombre_completo, "rfc": p.rfc, "curp": p.curp,
         "correo": p.correo, "contrasena": hash_pass, "rol": p.id_rol}
    )
    db.commit()
    return {"mensaje": "Personal registrado exitosamente"}

@router.delete("/{id_personal}")
def desactivar_personal(id_personal: int, db: Session = Depends(get_db)):
    db.execute(
        "UPDATE personal SET activo = FALSE WHERE id_personal = :id",
        {"id": id_personal}
    )
    db.commit()
    return {"mensaje": "Personal desactivado"}

@router.patch("/{id_personal}/reactivar")
def reactivar_personal(id_personal: int, db: Session = Depends(get_db)):
    db.execute(
        "UPDATE personal SET activo = TRUE WHERE id_personal = :id",
        {"id": id_personal}
    )
    db.commit()
    return {"mensaje": "Personal reactivado"}