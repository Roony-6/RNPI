from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.auth.security import solo_director, usuario_actual
from app.database import get_db
from app.models.catalogos import CatRol
from app.models.core import NNA, NnaPlantilla, Personal, Plantilla, PlantillaPersonal
from app.schemas.plantilla import (
    AsignacionNnaRespuesta,
    IntegranteAgregar,
    IntegranteRespuesta,
    NnaAsignar,
    PlantillaActualizar,
    PlantillaCrear,
    PlantillaRespuesta,
)

router = APIRouter(prefix="/plantillas", tags=["Plantillas"])

# Regla C: una sola persona por rol en cada plantilla, salvo roles directivos.
ROLES_EXENTOS = ("director", "coordinador")


def _nombre_completo(p: Personal) -> str:
    return " ".join(x for x in (p.nom_personal, p.prim_ap_personal, p.seg_ap_personal) if x)


def _serializar_plantilla(pl: Plantilla) -> PlantillaRespuesta:
    return PlantillaRespuesta(
        id_plantilla=pl.id_plantilla,
        nombre_plantilla=pl.nombre_plantilla,
        activa=pl.activa,
        integrantes=[
            IntegranteRespuesta(
                id_personal=i.personal.id_personal,
                nombre=_nombre_completo(i.personal),
                id_rol=i.personal.id_rol,
                rol=i.personal.rol.nombre_rol if i.personal.rol else "",
            )
            for i in pl.integrantes
        ],
    )


def _serializar_asignacion(a: NnaPlantilla) -> AsignacionNnaRespuesta:
    return AsignacionNnaRespuesta(
        id_nna_plantilla=a.id_nna_plantilla,
        id_nna=a.id_nna,
        folio_nna=a.nna.folio_nna,
        nombre_nna=" ".join(x for x in (a.nna.nom_nna, a.nna.prim_ap_nna, a.nna.seg_ap_nna) if x),
        id_plantilla=a.id_plantilla,
        nombre_plantilla=a.plantilla.nombre_plantilla,
        fecha_asignacion=a.fecha_asignacion,
        activa=a.activa,
    )


def _consulta_plantillas(db: Session):
    return db.query(Plantilla).options(
        joinedload(Plantilla.integrantes)
        .joinedload(PlantillaPersonal.personal)
        .joinedload(Personal.rol)
    )


def _obtener_plantilla_o_404(db: Session, id_plantilla: int) -> Plantilla:
    plantilla = db.get(Plantilla, id_plantilla)
    if not plantilla:
        raise HTTPException(status_code=404, detail="Plantilla no encontrada")
    return plantilla


# CRUD de plantillas

@router.get("", response_model=list[PlantillaRespuesta])
def listar_plantillas(
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    registros = _consulta_plantillas(db).order_by(Plantilla.id_plantilla).all()
    return [_serializar_plantilla(pl) for pl in registros]


@router.post("", status_code=201)
def crear_plantilla(
    datos: PlantillaCrear,
    db: Session = Depends(get_db),
    _: Personal = Depends(solo_director),
):
    nombre = datos.nombre_plantilla.strip()
    if db.query(Plantilla).filter(Plantilla.nombre_plantilla == nombre).first():
        raise HTTPException(status_code=409, detail="Ya existe una plantilla con ese nombre")

    plantilla = Plantilla(nombre_plantilla=nombre, activa=datos.activa)
    db.add(plantilla)
    db.commit()
    db.refresh(plantilla)
    return {"mensaje": "Plantilla creada", "id_plantilla": plantilla.id_plantilla}


@router.get("/nna/{id_nna}", response_model=list[AsignacionNnaRespuesta])
def historial_plantillas_nna(
    id_nna: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    if not db.get(NNA, id_nna):
        raise HTTPException(status_code=404, detail="NNA no encontrado")
    registros = (
        db.query(NnaPlantilla)
        .options(joinedload(NnaPlantilla.plantilla), joinedload(NnaPlantilla.nna))
        .filter(NnaPlantilla.id_nna == id_nna)
        .order_by(NnaPlantilla.fecha_asignacion.desc(), NnaPlantilla.id_nna_plantilla.desc())
        .all()
    )
    return [_serializar_asignacion(a) for a in registros]


@router.get("/{id_plantilla}", response_model=PlantillaRespuesta)
def detalle_plantilla(
    id_plantilla: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    plantilla = _consulta_plantillas(db).filter(Plantilla.id_plantilla == id_plantilla).first()
    if not plantilla:
        raise HTTPException(status_code=404, detail="Plantilla no encontrada")
    return _serializar_plantilla(plantilla)


@router.put("/{id_plantilla}", response_model=PlantillaRespuesta)
def actualizar_plantilla(
    id_plantilla: int,
    datos: PlantillaActualizar,
    db: Session = Depends(get_db),
    _: Personal = Depends(solo_director),
):
    plantilla = _obtener_plantilla_o_404(db, id_plantilla)
    nombre = datos.nombre_plantilla.strip()
    if db.query(Plantilla).filter(
        Plantilla.nombre_plantilla == nombre, Plantilla.id_plantilla != id_plantilla
    ).first():
        raise HTTPException(status_code=409, detail="Ya existe una plantilla con ese nombre")

    plantilla.nombre_plantilla = nombre
    plantilla.activa = datos.activa
    db.commit()
    plantilla = _consulta_plantillas(db).filter(Plantilla.id_plantilla == id_plantilla).first()
    return _serializar_plantilla(plantilla)


# Integrantes (plantilla_personal) — aquí vive la Regla C

@router.post("/{id_plantilla}/personal", status_code=201)
def agregar_integrante(
    id_plantilla: int,
    datos: IntegranteAgregar,
    db: Session = Depends(get_db),
    _: Personal = Depends(solo_director),
):
    _obtener_plantilla_o_404(db, id_plantilla)

    persona = db.get(Personal, datos.id_personal)
    if not persona:
        raise HTTPException(status_code=404, detail="Personal no encontrado")

    if db.get(PlantillaPersonal, (id_plantilla, datos.id_personal)):
        raise HTTPException(status_code=409, detail="Esa persona ya es integrante de la plantilla")

    rol = db.get(CatRol, persona.id_rol)
    nombre_rol = rol.nombre_rol if rol else ""
    exento = any(x in nombre_rol.lower() for x in ROLES_EXENTOS)

    if not exento:
        rol_ocupado = (
            db.query(PlantillaPersonal)
            .join(Personal, PlantillaPersonal.id_personal == Personal.id_personal)
            .filter(
                PlantillaPersonal.id_plantilla == id_plantilla,
                Personal.id_rol == persona.id_rol,
            )
            .first()
        )
        if rol_ocupado:
            raise HTTPException(
                status_code=400,
                detail=f"La plantilla ya cuenta con un integrante con el rol «{nombre_rol}»; "
                       "solo se permite una persona por rol",
            )

    db.add(PlantillaPersonal(id_plantilla=id_plantilla, id_personal=datos.id_personal))
    db.commit()
    return {"mensaje": "Integrante agregado a la plantilla"}


@router.delete("/{id_plantilla}/personal/{id_personal}", status_code=204)
def quitar_integrante(
    id_plantilla: int,
    id_personal: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(solo_director),
):
    integrante = db.get(PlantillaPersonal, (id_plantilla, id_personal))
    if not integrante:
        raise HTTPException(status_code=404, detail="Esa persona no es integrante de la plantilla")
    db.delete(integrante)
    db.commit()


# Asignación de plantillas a NNA (nna_plantilla — historial legal)

@router.post("/{id_plantilla}/nna", status_code=201)
def asignar_nna(
    id_plantilla: int,
    datos: NnaAsignar,
    db: Session = Depends(get_db),
    _: Personal = Depends(solo_director),
):
    plantilla = _obtener_plantilla_o_404(db, id_plantilla)
    if not plantilla.activa:
        raise HTTPException(status_code=400, detail="No se puede asignar una plantilla inactiva")
    if not db.get(NNA, datos.id_nna):
        raise HTTPException(status_code=404, detail="NNA no encontrado")

    anterior = (
        db.query(NnaPlantilla)
        .filter(NnaPlantilla.id_nna == datos.id_nna, NnaPlantilla.activa.is_(True))
        .first()
    )
    if anterior and anterior.id_plantilla == id_plantilla:
        raise HTTPException(status_code=400, detail="El NNA ya está asignado a esta plantilla")
    if anterior:
        # Se desactiva (no se borra): la asignación previa es historial legal.
        anterior.activa = False
        db.flush()

    asignacion = NnaPlantilla(
        id_nna=datos.id_nna,
        id_plantilla=id_plantilla,
        fecha_asignacion=datos.fecha_asignacion or date.today(),
        activa=True,
    )
    db.add(asignacion)
    db.commit()
    return {"mensaje": "Plantilla asignada al NNA", "id_nna_plantilla": asignacion.id_nna_plantilla}


@router.get("/{id_plantilla}/nna", response_model=list[AsignacionNnaRespuesta])
def listar_nna_de_plantilla(
    id_plantilla: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    _obtener_plantilla_o_404(db, id_plantilla)
    registros = (
        db.query(NnaPlantilla)
        .options(joinedload(NnaPlantilla.plantilla), joinedload(NnaPlantilla.nna))
        .filter(NnaPlantilla.id_plantilla == id_plantilla, NnaPlantilla.activa.is_(True))
        .order_by(NnaPlantilla.fecha_asignacion.desc())
        .all()
    )
    return [_serializar_asignacion(a) for a in registros]
