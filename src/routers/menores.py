from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.database import get_db
from pydantic import BaseModel
from datetime import date
from typing import Optional

router = APIRouter()

# --- Schemas (lo que entra y sale de la API) ---

class MenorCreate(BaseModel):
    nombre_completo: str
    curp: str
    fecha_nacimiento: date
    id_celula_asignada: int
    id_estatus: int

class MenorOut(MenorCreate):
    id_menor: int
    fecha_registro: str

    class Config:
        from_attributes = True  # Permite leer objetos SQLAlchemy


# --- Endpoints ---

@router.get("/", response_model=list[MenorOut])
def listar_menores(db: Session = Depends(get_db)):
    resultado = db.execute("SELECT * FROM menores").fetchall()
    return [dict(r._mapping) for r in resultado]


@router.get("/{id_menor}")
def obtener_menor(id_menor: int, db: Session = Depends(get_db)):
    resultado = db.execute(
        "SELECT * FROM menores WHERE id_menor = :id",
        {"id": id_menor}
    ).fetchone()
    if not resultado:
        raise HTTPException(status_code=404, detail="Menor no encontrado")
    return dict(resultado._mapping)


@router.post("/", status_code=201)
def registrar_menor(menor: MenorCreate, db: Session = Depends(get_db)):
    db.execute(
        """INSERT INTO menores 
           (nombre_completo, curp, fecha_nacimiento, id_celula_asignada, id_estatus)
           VALUES (:nombre, :curp, :fecha, :celula, :estatus)""",
        {
            "nombre": menor.nombre_completo,
            "curp": menor.curp,
            "fecha": menor.fecha_nacimiento,
            "celula": menor.id_celula_asignada,
            "estatus": menor.id_estatus
        }
    )
    db.commit()
    return {"mensaje": "Menor registrado exitosamente"}


@router.put("/{id_menor}/estatus")
def actualizar_estatus(id_menor: int, id_estatus: int, db: Session = Depends(get_db)):
    db.execute(
        "UPDATE menores SET id_estatus = :estatus WHERE id_menor = :id",
        {"estatus": id_estatus, "id": id_menor}
    )
    db.commit()
    return {"mensaje": "Estatus actualizado"}