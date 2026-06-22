from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.auth.security import hash_password, solo_director, usuario_actual
from app.database import get_db
from app.models.catalogos import CatRol
from app.models.core import Personal, PersonalLengua
from app.schemas.personal import (
    AccesoActualizar,
    LenguaPersonalRespuesta,
    PersonalActualizar,
    PersonalCrear,
    PersonalRespuesta,
)

router = APIRouter(prefix="/personal", tags=["Personal"])


def _serializar_personal(p: Personal) -> PersonalRespuesta:
    return PersonalRespuesta(
        id_personal=p.id_personal,
        nom_personal=p.nom_personal,
        prim_ap_personal=p.prim_ap_personal,
        seg_ap_personal=p.seg_ap_personal,
        rfc=p.rfc,
        curp=p.curp,
        correo=p.correo,
        id_rol=p.id_rol,
        activo=p.activo,
        lenguas=[
            LenguaPersonalRespuesta(
                id_len=l.id_len,
                lengua=l.lengua.nombre,
                nivel_competencia=l.nivel.descripcion if l.nivel else None,
                modo_adquisicion=l.modo.descripcion if l.modo else None,
                preferente_len_personal=l.preferente_len_personal,
                autodenom_len_personal=l.autodenom_len_personal,
            )
            for l in p.lenguas
        ],
    )


def _consulta_personal(db: Session):
    return db.query(Personal).options(
        joinedload(Personal.lenguas).joinedload(PersonalLengua.lengua),
        joinedload(Personal.lenguas).joinedload(PersonalLengua.nivel),
        joinedload(Personal.lenguas).joinedload(PersonalLengua.modo),
    )


@router.get("", response_model=list[PersonalRespuesta])
def listar_personal(
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    registros = _consulta_personal(db).order_by(Personal.id_personal).all()
    return [_serializar_personal(p) for p in registros]


@router.get("/{id_personal}", response_model=PersonalRespuesta)
def obtener_personal(
    id_personal: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    persona = _consulta_personal(db).filter(Personal.id_personal == id_personal).first()
    if not persona:
        raise HTTPException(status_code=404, detail="Personal no encontrado")
    return _serializar_personal(persona)


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
        nom_personal=datos.nom_personal.strip(),
        prim_ap_personal=datos.prim_ap_personal.strip(),
        seg_ap_personal=datos.seg_ap_personal.strip() if datos.seg_ap_personal else None,
        rfc=datos.rfc.upper(),
        curp=datos.curp.upper(),
        correo=datos.correo,
        contrasena=hash_password(datos.contrasena),
        id_rol=datos.id_rol,
        activo=True,
    )
    db.add(nueva_persona)
    db.flush()

    for lng in datos.lenguas:
        db.add(PersonalLengua(
            id_personal=nueva_persona.id_personal,
            id_len=lng.id_len,
            id_niv_com=lng.id_niv_com,
            id_mod_adc=lng.id_mod_adc,
            preferente_len_personal=lng.preferente_len_personal,
            autodenom_len_personal=lng.autodenom_len_personal,
        ))

    db.commit()
    db.refresh(nueva_persona)
    return _serializar_personal(nueva_persona)


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

    persona.nom_personal     = datos.nom_personal.strip()
    persona.prim_ap_personal = datos.prim_ap_personal.strip()
    persona.seg_ap_personal  = datos.seg_ap_personal.strip() if datos.seg_ap_personal else None
    persona.rfc              = datos.rfc.upper()
    persona.curp             = datos.curp.upper()
    persona.correo           = datos.correo
    persona.id_rol           = datos.id_rol

    db.query(PersonalLengua).filter(PersonalLengua.id_personal == id_personal).delete(synchronize_session=False)
    for lng in datos.lenguas:
        db.add(PersonalLengua(
            id_personal=id_personal,
            id_len=lng.id_len,
            id_niv_com=lng.id_niv_com,
            id_mod_adc=lng.id_mod_adc,
            preferente_len_personal=lng.preferente_len_personal,
            autodenom_len_personal=lng.autodenom_len_personal,
        ))

    db.commit()
    db.refresh(persona)
    return _serializar_personal(persona)


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
