from pydantic import BaseModel, EmailStr
from typing import Optional


class LenguaPersonalCrear(BaseModel):
    id_len:                 int
    id_niv_com:             Optional[int] = None
    id_mod_adc:             Optional[int] = None
    preferente_len_personal: bool = False
    autodenom_len_personal:  Optional[str] = None


class LenguaPersonalRespuesta(BaseModel):
    id_len:                  int
    lengua:                  str
    nivel_competencia:       Optional[str] = None
    modo_adquisicion:        Optional[str] = None
    preferente_len_personal: bool
    autodenom_len_personal:  Optional[str] = None


class PersonalBase(BaseModel):
    nom_personal:     str
    prim_ap_personal: str
    seg_ap_personal:  str | None = None
    rfc:              str
    curp:             str
    correo:           EmailStr
    id_rol:           int


class PersonalCrear(PersonalBase):
    contrasena: str
    lenguas:    list[LenguaPersonalCrear] = []


class PersonalActualizar(PersonalBase):
    lenguas: list[LenguaPersonalCrear] = []


class PersonalRespuesta(PersonalBase):
    id_personal: int
    activo:      bool
    lenguas:     list[LenguaPersonalRespuesta] = []
    model_config = {"from_attributes": True}


class AccesoActualizar(BaseModel):
    activo: bool


class RolRespuesta(BaseModel):
    id_rol:     int
    nombre_rol: str
    model_config = {"from_attributes": True}


class TokenRespuesta(BaseModel):
    access_token: str
    token_type:   str
    usuario:      PersonalRespuesta
