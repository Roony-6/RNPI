from fastapi import APIRouter, Depends
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.auth.security import usuario_actual
from app.database import get_db
from app.models.catalogos import (
    Asentamiento,
    CatCieSubcategoria,
    CatDiscapacidad,
    CatEstatusJuridico,
    CatGradoDependencia,
    CatMedidaProteccion,
    CatLengua,
    CatModoAdquisicionLengua,
    CatNacionalidad,
    CatNivelCompetenciaOral,
    CatRol,
    CatSexo,
    CatTipoContacto,
    EntidadFederativa,
)
from app.models.core import Personal
from app.schemas.personal import RolRespuesta

router = APIRouter(prefix="/catalogos", tags=["Catálogos"])


@router.get("/roles", response_model=list[RolRespuesta])
def listar_roles(
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    return db.query(CatRol).order_by(CatRol.id_rol).all()


# Geografía (5NF: entidad_federativa / asentamiento)

@router.get("/entidades")
def obtener_entidades(db: Session = Depends(get_db)):
    entidades = db.query(EntidadFederativa).order_by(EntidadFederativa.nom_ent).all()
    return [{"id": e.id_ent, "nombre": e.nom_ent} for e in entidades]


@router.get("/asentamientos/{id_ent}")
def obtener_asentamientos(id_ent: int, db: Session = Depends(get_db)):
    asentamientos = (
        db.query(Asentamiento)
        .filter(Asentamiento.id_ent == id_ent)
        .order_by(Asentamiento.nom_mun, Asentamiento.nom_col)
        .all()
    )
    return [
        {
            "id":        a.id_asen,
            "municipio": a.nom_mun,
            "colonia":   a.nom_col,
            "cp":        a.cp_asen,
        }
        for a in asentamientos
    ]


# Catálogos de la persona (NNA)

@router.get("/sexos")
def obtener_sexos(db: Session = Depends(get_db)):
    filas = db.query(CatSexo).order_by(CatSexo.id_sexo).all()
    return [{"id": f.id_sexo, "nombre": f.nombre} for f in filas]


@router.get("/nacionalidades")
def obtener_nacionalidades(db: Session = Depends(get_db)):
    filas = db.query(CatNacionalidad).order_by(CatNacionalidad.id_nac).all()
    return [{"id": f.id_nac, "nombre": f.nombre} for f in filas]


@router.get("/tipos_contacto")
def obtener_tipos_contacto(db: Session = Depends(get_db)):
    filas = db.query(CatTipoContacto).order_by(CatTipoContacto.id_tipo_con).all()
    return [{"id": f.id_tipo_con, "nombre": f.nombre} for f in filas]


@router.get("/lenguas")
def obtener_lenguas(db: Session = Depends(get_db)):
    filas = db.query(CatLengua).order_by(CatLengua.nombre).all()
    return [{"id": f.id_len, "nombre": f.nombre, "es_indigena": f.es_indigena} for f in filas]


@router.get("/niveles_competencia_oral")
def obtener_niveles_competencia(db: Session = Depends(get_db)):
    filas = db.query(CatNivelCompetenciaOral).order_by(CatNivelCompetenciaOral.id_niv_com).all()
    return [{"id": f.id_niv_com, "nombre": f.descripcion} for f in filas]


@router.get("/modos_adquisicion_lengua")
def obtener_modos_adquisicion(db: Session = Depends(get_db)):
    filas = db.query(CatModoAdquisicionLengua).order_by(CatModoAdquisicionLengua.id_mod_adc).all()
    return [{"id": f.id_mod_adc, "nombre": f.descripcion} for f in filas]


@router.get("/discapacidades")
def obtener_discapacidades(db: Session = Depends(get_db)):
    filas = db.query(CatDiscapacidad).order_by(CatDiscapacidad.id_dis).all()
    return [{"id": f.id_dis, "nombre": f.nombre} for f in filas]


@router.get("/grados_dependencia")
def obtener_grados_dependencia(db: Session = Depends(get_db)):
    filas = db.query(CatGradoDependencia).order_by(CatGradoDependencia.id_gra_dep).all()
    return [{"id": f.id_gra_dep, "nombre": f.descripcion} for f in filas]


# Catálogos legales

@router.get("/estatus_juridico")
def obtener_estatus_juridico(db: Session = Depends(get_db)):
    filas = db.query(CatEstatusJuridico).order_by(CatEstatusJuridico.id_est_jur).all()
    return [{"id": f.id_est_jur, "nombre": f.nombre} for f in filas]


@router.get("/medidas_proteccion")
def obtener_medidas_proteccion(db: Session = Depends(get_db)):
    filas = db.query(CatMedidaProteccion).order_by(CatMedidaProteccion.id_med_pro).all()
    return [{"id": f.id_med_pro, "nombre": f.nombre} for f in filas]


# CIE-10

@router.get("/cie10_comunes")
def obtener_cie10_comunes(db: Session = Depends(get_db)):
    terminos = [
        "%diabetes%", "%hipertensi%", "%asma%", "%obesidad%",
        "%depresion%", "%epilepsia%", "%anemia%", "%artritis%",
        "%cancer%", "%cardio%",
    ]
    filtros    = [CatCieSubcategoria.descripcion.ilike(t) for t in terminos]
    resultados = db.query(CatCieSubcategoria).filter(or_(*filtros)).limit(20).all()
    return [
        {"id": r.id_subcategoria, "codigo_subcategoria": r.codigo, "descripcion": r.descripcion}
        for r in resultados
    ]


@router.get("/cie10_buscar")
def buscar_cie10(q: str = "", db: Session = Depends(get_db)):
    if not q or len(q.strip()) < 2:
        return []
    termino    = f"%{q.strip()}%"
    resultados = (
        db.query(CatCieSubcategoria)
        .filter(
            CatCieSubcategoria.descripcion.ilike(termino)
            | CatCieSubcategoria.codigo.ilike(termino)
        )
        .order_by(CatCieSubcategoria.codigo)
        .limit(15)
        .all()
    )
    return [
        {"id": r.id_subcategoria, "codigo_subcategoria": r.codigo, "descripcion": r.descripcion}
        for r in resultados
    ]
