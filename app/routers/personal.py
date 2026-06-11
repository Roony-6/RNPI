from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.auth.security import hash_password, solo_director, usuario_actual
from app.database import get_db
from app.models.catalogos import CatRol
from app.models.core import Personal
from app.schemas.personal import (
    AccesoActualizar,
    PersonalActualizar,
    PersonalCrear,
    PersonalRespuesta,
)

router = APIRouter(prefix="/personal", tags=["Personal"])


@router.get("", response_model=list[PersonalRespuesta])
def listar_personal(
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    return db.query(Personal).order_by(Personal.id_personal).all()


@router.get("/{id_personal}", response_model=PersonalRespuesta)
def obtener_personal(
    id_personal: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    persona = db.get(Personal, id_personal)
    if not persona:
        raise HTTPException(status_code=404, detail="Personal no encontrado")
    return persona


@router.post("", response_model=PersonalRespuesta, status_code=201)
def registrar_personal(
    datos: PersonalCrear,
    db: Session = Depends(get_db),
    _: Personal = Depends(solo_director),
):
    if db.query(Personal).filter(Personal.correo == datos.correo).first():
        raise HTTPException(status_code=409, detail="Ya existe un registro con ese correo")
    if db.query(Personal).filter(Personal.rfc == datos.rfc).first():
        raise HTTPException(status_code=409, detail="Ya existe un registro con ese RFC")
    if db.query(Personal).filter(Personal.curp == datos.curp).first():
        raise HTTPException(status_code=409, detail="Ya existe un registro con esa CURP")
    if not db.get(CatRol, datos.id_rol):
        raise HTTPException(status_code=400, detail="El rol indicado no existe")

    nueva_persona = Personal(
        nombre_completo=datos.nombre_completo,
        rfc=datos.rfc.upper(),
        curp=datos.curp.upper(),
        correo=datos.correo,
        contrasena=hash_password(datos.contrasena),
        id_rol=datos.id_rol,
        activo=True,
    )
    db.add(nueva_persona)
    db.commit()
    db.refresh(nueva_persona)
    return nueva_persona


@router.put("/{id_personal}", response_model=PersonalRespuesta)
def actualizar_personal(
    id_personal: int,
    datos: PersonalActualizar,
    db: Session = Depends(get_db),
    _: Personal = Depends(solo_director),
):
    persona = db.get(Personal, id_personal)
    if not persona:
        raise HTTPException(status_code=404, detail="Personal no encontrado")

    if db.query(Personal).filter(
        Personal.correo == datos.correo, Personal.id_personal != id_personal
    ).first():
        raise HTTPException(status_code=409, detail="El correo ya está en uso por otro registro")
    if db.query(Personal).filter(
        Personal.rfc == datos.rfc, Personal.id_personal != id_personal
    ).first():
        raise HTTPException(status_code=409, detail="El RFC ya está en uso por otro registro")
    if db.query(Personal).filter(
        Personal.curp == datos.curp, Personal.id_personal != id_personal
    ).first():
        raise HTTPException(status_code=409, detail="La CURP ya está en uso por otro registro")

    if not db.get(CatRol, datos.id_rol):
        raise HTTPException(status_code=400, detail="El rol indicado no existe")

    persona.nombre_completo = datos.nombre_completo
    persona.rfc             = datos.rfc.upper()
    persona.curp            = datos.curp.upper()
    persona.correo          = datos.correo
    persona.id_rol          = datos.id_rol
    db.commit()
    db.refresh(persona)
    return persona


@router.patch("/{id_personal}/acceso", response_model=PersonalRespuesta)
def cambiar_acceso(
    id_personal: int,
    datos: AccesoActualizar,
    db: Session = Depends(get_db),
    director: Personal = Depends(solo_director),
):
    persona = db.get(Personal, id_personal)
    if not persona:
        raise HTTPException(status_code=404, detail="Personal no encontrado")
    if persona.id_personal == director.id_personal:
        raise HTTPException(status_code=400, detail="No puede revocar su propio acceso")

    persona.activo = datos.activo
    db.commit()
    db.refresh(persona)
    return persona


@router.delete("/{id_personal}", status_code=204)
def eliminar_personal(
    id_personal: int,
    db: Session = Depends(get_db),
    director: Personal = Depends(solo_director),
):
    persona = db.get(Personal, id_personal)
    if not persona:
        raise HTTPException(status_code=404, detail="Personal no encontrado")
    if persona.id_personal == director.id_personal:
        raise HTTPException(status_code=400, detail="No puede eliminar su propio registro")

    db.delete(persona)
    db.commit()
