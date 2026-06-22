from datetime import date
from typing import Optional

from pydantic import BaseModel


# ---------------------------------------------------------------------------
# Esquemas de creación
# ---------------------------------------------------------------------------

class DireccionCrear(BaseModel):
    calle_dir:  str
    no_ext_dir: Optional[str] = None
    no_int_dir: Optional[str] = None
    id_asen:    int
    ref_dir:    Optional[str] = None


class TutorCrear(BaseModel):
    nom_tutor:     str
    prim_ap_tutor: str
    seg_ap_tutor:  Optional[str] = None
    curp_tutor:    str


class ContactoNnaCrear(BaseModel):
    id_tipo_con: int
    text_con:    str
    desc_con:    Optional[str] = None


class LenguaNnaCrear(BaseModel):
    id_len:             int
    id_niv_com:         Optional[int] = None
    id_mod_adc:         Optional[int] = None
    preferente_len_nna: bool = False
    autodenom_len_nna:  Optional[str] = None


class DiscapacidadNnaCrear(BaseModel):
    id_dis:       int
    id_gra_dep:   Optional[int] = None
    diagnost_dis: bool = False


class PadecimientoCrear(BaseModel):
    id_subcategoria:   int
    es_cronico:        bool = False
    esta_controlado:   bool = False
    fecha_diagnostico: Optional[date] = None
    notas_clinicas:    Optional[str] = None


class SituacionLegalCrear(BaseModel):
    id_est_jur:    int
    id_med_pro:    Optional[int] = None
    fecha_inicio:  Optional[date] = None
    observaciones: Optional[str] = None


class NnaCrear(BaseModel):
    nom_nna:        str
    prim_ap_nna:    str
    seg_ap_nna:     Optional[str] = None
    nacim_nna:      date
    curp_nna:       str
    id_sexo:        int
    luga_nac_nna:   Optional[int] = None
    direccion:      Optional[DireccionCrear] = None
    tutores:        list[TutorCrear] = []
    nacionalidades: list[int] = []
    contactos:      list[ContactoNnaCrear] = []
    lenguas:        list[LenguaNnaCrear] = []
    discapacidades: list[DiscapacidadNnaCrear] = []


# ---------------------------------------------------------------------------
# Esquemas de respuesta
# ---------------------------------------------------------------------------

class TutorRespuesta(BaseModel):
    id_tutor:      int
    nom_tutor:     str
    prim_ap_tutor: str
    seg_ap_tutor:  Optional[str] = None
    curp_tutor:    str
    model_config = {"from_attributes": True}


class DireccionRespuesta(BaseModel):
    id_dir:     int
    calle_dir:  str
    no_ext_dir: Optional[str] = None
    no_int_dir: Optional[str] = None
    id_asen:    int
    ref_dir:    Optional[str] = None
    model_config = {"from_attributes": True}


class ContactoNnaRespuesta(BaseModel):
    id_contacto: int
    id_tipo_con: int
    tipo:        str
    text_con:    str
    desc_con:    Optional[str] = None


class LenguaNnaRespuesta(BaseModel):
    id_len:             int
    lengua:             str
    nivel_competencia:  Optional[str] = None
    modo_adquisicion:   Optional[str] = None
    preferente_len_nna: bool
    autodenom_len_nna:  Optional[str] = None


class DiscapacidadNnaRespuesta(BaseModel):
    id_dis:           int
    discapacidad:     str
    grado_dependencia: Optional[str] = None
    diagnost_dis:     bool


class PadecimientoRespuesta(BaseModel):
    id_padecimiento:   int
    id_subcategoria:   int
    codigo_cie10:      str
    diagnostico:       str
    es_cronico:        bool
    esta_controlado:   bool
    fecha_diagnostico: date
    notas_clinicas:    Optional[str] = None


class SituacionLegalRespuesta(BaseModel):
    id_sit_legal:      int
    id_est_jur:        int
    estatus_juridico:  str
    id_med_pro:        Optional[int] = None
    medida_proteccion: Optional[str] = None
    fecha_inicio:      date
    observaciones:     Optional[str] = None


class NnaRespuesta(BaseModel):
    id_nna:           int
    folio_nna:        str
    nom_nna:          str
    prim_ap_nna:      str
    seg_ap_nna:       Optional[str] = None
    nacim_nna:        date
    curp_nna:         str
    sexo:             str
    lugar_nacimiento: Optional[str] = None
    direccion:        Optional[str] = None
    tutores:          list[TutorRespuesta] = []
    nacionalidades:   list[str] = []
    contactos:        list[ContactoNnaRespuesta] = []
    lenguas:          list[LenguaNnaRespuesta] = []
    discapacidades:   list[DiscapacidadNnaRespuesta] = []
