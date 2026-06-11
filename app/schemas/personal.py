from pydantic import BaseModel, EmailStr


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


class PersonalActualizar(PersonalBase):
    pass


class PersonalRespuesta(PersonalBase):
    id_personal: int
    activo:      bool
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
