from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.database import get_db
from pydantic import BaseModel

router = APIRouter()

class CelulaCreate(BaseModel):
    nombre_celula: str
    id_municipio: int

class IntegranteAdd(BaseModel):
    id_personal: int

@router.get("/")
def listar_celulas(db: Session = Depends(get_db)):
    resultado = db.execute("SELECT * FROM celulas").fetchall()
    return [dict(r._mapping) for r in resultado]

@router.get("/{id_celula}")
def obtener_celula(id_celula: int, db: Session = Depends(get_db)):
    celula = db.execute(
        "SELECT * FROM celulas WHERE id_celula = :id",
        {"id": id_celula}
    ).fetchone()
    if not celula:
        raise HTTPException(status_code=404, detail="Célula no encontrada")
    integrantes = db.execute(
        """SELECT p.id_personal, p.nombre_completo, p.correo, r.nombre_rol
           FROM celula_integrantes ci
           JOIN personal p ON ci.id_personal = p.id_personal
           JOIN cat_roles r ON p.id_rol = r.id_rol
           WHERE ci.id_celula = :id""",
        {"id": id_celula}
    ).fetchall()
    return {
        **dict(celula._mapping),
        "integrantes": [dict(i._mapping) for i in integrantes]
    }

@router.post("/", status_code=201)
def crear_celula(c: CelulaCreate, db: Session = Depends(get_db)):
    db.execute(
        "INSERT INTO celulas (nombre_celula, id_municipio) VALUES (:nombre, :municipio)",
        {"nombre": c.nombre_celula, "municipio": c.id_municipio}
    )
    db.commit()
    return {"mensaje": "Célula creada exitosamente"}

@router.post("/{id_celula}/integrantes", status_code=201)
def agregar_integrante(id_celula: int, integrante: IntegranteAdd, db: Session = Depends(get_db)):
    db.execute(
        "INSERT INTO celula_integrantes (id_celula, id_personal) VALUES (:celula, :personal)",
        {"celula": id_celula, "personal": integrante.id_personal}
    )
    db.commit()
    return {"mensaje": "Integrante agregado a la célula"}

@router.delete("/{id_celula}/integrantes/{id_personal}")
def quitar_integrante(id_celula: int, id_personal: int, db: Session = Depends(get_db)):
    db.execute(
        "DELETE FROM celula_integrantes WHERE id_celula = :celula AND id_personal = :personal",
        {"celula": id_celula, "personal": id_personal}
    )
    db.commit()
    return {"mensaje": "Integrante removido de la célula"}