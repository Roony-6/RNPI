from datetime import date
from typing import Optional

from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# Esquemas de creación / mutación
# ---------------------------------------------------------------------------

class PlantillaCrear(BaseModel):
    nombre_plantilla: str = Field(min_length=3, max_length=150)
    activa:           bool = True


class PlantillaActualizar(BaseModel):
    nombre_plantilla: str = Field(min_length=3, max_length=150)
    activa:           bool


class IntegranteAgregar(BaseModel):
    id_personal: int


class NnaAsignar(BaseModel):
    id_nna:           int
    fecha_asignacion: Optional[date] = None


# ---------------------------------------------------------------------------
# Esquemas de respuesta
# ---------------------------------------------------------------------------

class IntegranteRespuesta(BaseModel):
    id_personal: int
    nombre:      str
    id_rol:      int
    rol:         str


class PlantillaRespuesta(BaseModel):
    id_plantilla:     int
    nombre_plantilla: str
    activa:           bool
    integrantes:      list[IntegranteRespuesta] = []


class AsignacionNnaRespuesta(BaseModel):
    id_nna_plantilla: int
    id_nna:           int
    folio_nna:        str
    nombre_nna:       str
    id_plantilla:     int
    nombre_plantilla: str
    fecha_asignacion: date
    activa:           bool
