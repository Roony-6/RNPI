from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.auth.security import usuario_actual
from app.database import get_db
from app.models.catalogos import (
    CatCieSubcategoria,
    CatEstatusJuridico,
    CatMedidaProteccion,
    Direccion,
)
from app.models.core import (
    NNA,
    ContactoNna,
    LenguajeNna,
    NacionalidadNna,
    NnaDiscapacidad,
    NnaPadecimiento,
    NnaSituacionLegal,
    NnaTutor,
    Personal,
    Tutor,
)
from app.schemas.nna import (
    ContactoNnaRespuesta,
    DiscapacidadNnaRespuesta,
    LenguaNnaRespuesta,
    NnaCrear,
    NnaRespuesta,
    PadecimientoCrear,
    PadecimientoRespuesta,
    SituacionLegalCrear,
    SituacionLegalRespuesta,
    TutorRespuesta,
)

router = APIRouter(prefix="/nna", tags=["NNA"])


def _serializar_nna(n: NNA) -> NnaRespuesta:
    direccion_txt = None
    if n.direccion_actual:
        d = n.direccion_actual
        a = d.asentamiento
        no_ext = f" {d.no_ext_dir}" if d.no_ext_dir else ""
        direccion_txt = f"{d.calle_dir}{no_ext}, {a.nom_col}, {a.nom_mun}, CP {a.cp_asen}"

    return NnaRespuesta(
        id_nna=n.id_nna,
        folio_nna=n.folio_nna,
        nom_nna=n.nom_nna,
        prim_ap_nna=n.prim_ap_nna,
        seg_ap_nna=n.seg_ap_nna,
        alias_nna=n.alias_nna,
        nacim_nna=n.nacim_nna,
        curp_nna=n.curp_nna,
        sexo=n.sexo.nombre,
        lugar_nacimiento=n.lugar_nacimiento.nom_ent if n.lugar_nacimiento else None,
        direccion=direccion_txt,
        tutores=[TutorRespuesta.model_validate(nt.tutor) for nt in n.nna_tutores],
        nacionalidades=[nn.nacionalidad.nombre for nn in n.nacionalidades],
        contactos=[
            ContactoNnaRespuesta(
                id_contacto=c.id_contacto,
                id_tipo_con=c.id_tipo_con,
                tipo=c.tipo.nombre,
                text_con=c.text_con,
                desc_con=c.desc_con,
            )
            for c in n.contactos
        ],
        lenguas=[
            LenguaNnaRespuesta(
                id_len=l.id_len,
                lengua=l.lengua.nombre,
                nivel_competencia=l.nivel.descripcion if l.nivel else None,
                modo_adquisicion=l.modo.descripcion if l.modo else None,
                preferente_len_nna=l.preferente_len_nna,
                autodenom_len_nna=l.autodenom_len_nna,
            )
            for l in n.lenguas
        ],
        discapacidades=[
            DiscapacidadNnaRespuesta(
                id_dis=d.id_dis,
                discapacidad=d.discapacidad.nombre,
                grado_dependencia=d.grado.descripcion if d.grado else None,
                diagnost_dis=d.diagnost_dis,
            )
            for d in n.discapacidades
        ],
    )


def _consulta_nna(db: Session):
    return db.query(NNA).options(
        joinedload(NNA.sexo),
        joinedload(NNA.lugar_nacimiento),
        joinedload(NNA.direccion_actual).joinedload(Direccion.asentamiento),
        joinedload(NNA.nna_tutores).joinedload(NnaTutor.tutor),
        joinedload(NNA.nacionalidades).joinedload(NacionalidadNna.nacionalidad),
        joinedload(NNA.contactos).joinedload(ContactoNna.tipo),
        joinedload(NNA.lenguas).joinedload(LenguajeNna.lengua),
        joinedload(NNA.lenguas).joinedload(LenguajeNna.nivel),
        joinedload(NNA.lenguas).joinedload(LenguajeNna.modo),
        joinedload(NNA.discapacidades).joinedload(NnaDiscapacidad.discapacidad),
        joinedload(NNA.discapacidades).joinedload(NnaDiscapacidad.grado),
    )


@router.post("", status_code=201)
def registrar_nna(
    datos: NnaCrear,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    curp = datos.curp_nna.strip().upper()
    if db.query(NNA).filter(NNA.curp_nna == curp).first():
        raise HTTPException(status_code=409, detail="Ya existe un NNA con esa CURP")

    id_dir = None
    if datos.direccion:
        direccion = Direccion(
            calle_dir=datos.direccion.calle_dir,
            no_ext_dir=datos.direccion.no_ext_dir,
            no_int_dir=datos.direccion.no_int_dir,
            id_asen=datos.direccion.id_asen,
            ref_dir=datos.direccion.ref_dir,
        )
        db.add(direccion)
        db.flush()
        id_dir = direccion.id_dir

    nna = NNA(
        folio_nna="PENDIENTE",
        nom_nna=datos.nom_nna,
        prim_ap_nna=datos.prim_ap_nna,
        seg_ap_nna=datos.seg_ap_nna,
        alias_nna=datos.alias_nna,
        nacim_nna=datos.nacim_nna,
        curp_nna=curp,
        id_sexo=datos.id_sexo,
        dir_actual=id_dir,
        luga_nac_nna=datos.luga_nac_nna,
    )
    db.add(nna)
    db.flush()
    nna.folio_nna = f"NNA-{nna.id_nna:05d}"

    for t in datos.tutores:
        curp_t = t.curp_tutor.strip().upper()
        tutor = db.query(Tutor).filter(Tutor.curp_tutor == curp_t).first()
        if not tutor:
            tutor = Tutor(
                nom_tutor=t.nom_tutor,
                prim_ap_tutor=t.prim_ap_tutor,
                seg_ap_tutor=t.seg_ap_tutor,
                curp_tutor=curp_t,
            )
            db.add(tutor)
            db.flush()
        db.add(NnaTutor(id_nna=nna.id_nna, id_tutor=tutor.id_tutor))

    for id_nac in datos.nacionalidades:
        db.add(NacionalidadNna(id_nna=nna.id_nna, id_nac=id_nac))

    for c in datos.contactos:
        db.add(ContactoNna(
            id_nna=nna.id_nna,
            id_tipo_con=c.id_tipo_con,
            text_con=c.text_con,
            desc_con=c.desc_con,
        ))

    for lng in datos.lenguas:
        db.add(LenguajeNna(
            id_nna=nna.id_nna,
            id_len=lng.id_len,
            id_niv_com=lng.id_niv_com,
            id_mod_adc=lng.id_mod_adc,
            preferente_len_nna=lng.preferente_len_nna,
            autodenom_len_nna=lng.autodenom_len_nna,
        ))

    for dis in datos.discapacidades:
        db.add(NnaDiscapacidad(
            id_nna=nna.id_nna,
            id_dis=dis.id_dis,
            id_gra_dep=dis.id_gra_dep,
            diagnost_dis=dis.diagnost_dis,
        ))

    db.commit()
    return {"mensaje": "NNA registrado con éxito", "id_nna": nna.id_nna, "folio_nna": nna.folio_nna}


@router.get("", response_model=list[NnaRespuesta])
def listar_nna(
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    registros = _consulta_nna(db).order_by(NNA.id_nna.desc()).all()
    return [_serializar_nna(n) for n in registros]


@router.get("/{id_nna}", response_model=NnaRespuesta)
def detalle_nna(
    id_nna: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    nna = _consulta_nna(db).filter(NNA.id_nna == id_nna).first()
    if not nna:
        raise HTTPException(status_code=404, detail="NNA no encontrado")
    return _serializar_nna(nna)


def _obtener_nna_o_404(db: Session, id_nna: int) -> NNA:
    nna = db.get(NNA, id_nna)
    if not nna:
        raise HTTPException(status_code=404, detail="NNA no encontrado")
    return nna


# ---------------------------------------------------------------------------
# Valoración Médica (nna_padecimiento — CIE-10)
# ---------------------------------------------------------------------------

@router.post("/{id_nna}/padecimientos", status_code=201)
def registrar_padecimiento(
    id_nna: int,
    datos: PadecimientoCrear,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    _obtener_nna_o_404(db, id_nna)
    if not db.get(CatCieSubcategoria, datos.id_subcategoria):
        raise HTTPException(status_code=404, detail="Diagnóstico CIE-10 no encontrado")

    padecimiento = NnaPadecimiento(
        id_nna=id_nna,
        id_subcategoria=datos.id_subcategoria,
        es_cronico=datos.es_cronico,
        esta_controlado=datos.esta_controlado,
        fecha_diagnostico=datos.fecha_diagnostico or date.today(),
        notas_clinicas=datos.notas_clinicas,
    )
    db.add(padecimiento)
    db.commit()
    return {"mensaje": "Valoración médica registrada", "id_padecimiento": padecimiento.id_padecimiento}


@router.get("/{id_nna}/padecimientos", response_model=list[PadecimientoRespuesta])
def listar_padecimientos(
    id_nna: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    _obtener_nna_o_404(db, id_nna)
    registros = (
        db.query(NnaPadecimiento)
        .options(joinedload(NnaPadecimiento.subcategoria))
        .filter(NnaPadecimiento.id_nna == id_nna)
        .order_by(NnaPadecimiento.fecha_diagnostico.desc())
        .all()
    )
    return [
        PadecimientoRespuesta(
            id_padecimiento=p.id_padecimiento,
            id_subcategoria=p.id_subcategoria,
            codigo_cie10=p.subcategoria.codigo,
            diagnostico=p.subcategoria.descripcion,
            es_cronico=p.es_cronico,
            esta_controlado=p.esta_controlado,
            fecha_diagnostico=p.fecha_diagnostico,
            notas_clinicas=p.notas_clinicas,
        )
        for p in registros
    ]


# ---------------------------------------------------------------------------
# Situación Legal (nna_situacion_legal)
# ---------------------------------------------------------------------------

@router.post("/{id_nna}/situacion_legal", status_code=201)
def registrar_situacion_legal(
    id_nna: int,
    datos: SituacionLegalCrear,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    _obtener_nna_o_404(db, id_nna)
    if not db.get(CatEstatusJuridico, datos.id_est_jur):
        raise HTTPException(status_code=404, detail="Estatus jurídico no encontrado")
    if datos.id_med_pro and not db.get(CatMedidaProteccion, datos.id_med_pro):
        raise HTTPException(status_code=404, detail="Medida de protección no encontrada")

    situacion = NnaSituacionLegal(
        id_nna=id_nna,
        id_est_jur=datos.id_est_jur,
        id_med_pro=datos.id_med_pro,
        fecha_inicio=datos.fecha_inicio or date.today(),
        observaciones=datos.observaciones,
    )
    db.add(situacion)
    db.commit()
    return {"mensaje": "Situación legal registrada", "id_sit_legal": situacion.id_sit_legal}


@router.get("/{id_nna}/situacion_legal", response_model=list[SituacionLegalRespuesta])
def listar_situacion_legal(
    id_nna: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    _obtener_nna_o_404(db, id_nna)
    registros = (
        db.query(NnaSituacionLegal)
        .options(
            joinedload(NnaSituacionLegal.estatus),
            joinedload(NnaSituacionLegal.medida),
        )
        .filter(NnaSituacionLegal.id_nna == id_nna)
        .order_by(NnaSituacionLegal.fecha_inicio.desc())
        .all()
    )
    return [
        SituacionLegalRespuesta(
            id_sit_legal=s.id_sit_legal,
            id_est_jur=s.id_est_jur,
            estatus_juridico=s.estatus.nombre,
            id_med_pro=s.id_med_pro,
            medida_proteccion=s.medida.nombre if s.medida else None,
            fecha_inicio=s.fecha_inicio,
            observaciones=s.observaciones,
        )
        for s in registros
    ]


@router.delete("/{id_nna}", status_code=204)
def eliminar_nna(
    id_nna: int,
    db: Session = Depends(get_db),
    _: Personal = Depends(usuario_actual),
):
    nna = db.get(NNA, id_nna)
    if not nna:
        raise HTTPException(status_code=404, detail="NNA no encontrado")
    # Las tablas pivote se limpian por ON DELETE CASCADE en la BD
    db.query(NNA).filter(NNA.id_nna == id_nna).delete(synchronize_session=False)
    db.commit()
