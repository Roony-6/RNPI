from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from src.database import get_db

router = APIRouter()

@router.get("/estados")
def listar_estados(db: Session = Depends(get_db)):
    resultado = db.execute("SELECT * FROM cat_estados").fetchall()
    return [dict(r._mapping) for r in resultado]

@router.get("/municipios")
def listar_municipios(db: Session = Depends(get_db)):
    resultado = db.execute("SELECT * FROM cat_municipios").fetchall()
    return [dict(r._mapping) for r in resultado]

@router.get("/roles")
def listar_roles(db: Session = Depends(get_db)):
    resultado = db.execute("SELECT * FROM cat_roles").fetchall()
    return [dict(r._mapping) for r in resultado]

@router.get("/estatus")
def listar_estatus(db: Session = Depends(get_db)):
    resultado = db.execute("SELECT * FROM cat_estatus_menor").fetchall()
    return [dict(r._mapping) for r in resultado]