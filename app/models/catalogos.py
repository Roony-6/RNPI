from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.database import Base


# ---------------------------------------------------------------------------
# Tablas geográficas
# ---------------------------------------------------------------------------

class EntidadFederativa(Base):
    __tablename__ = "entidad_federativa"

    id_ent  = Column(Integer,     primary_key=True, index=True)
    nom_ent = Column(String(200), nullable=False)

    asentamientos = relationship("Asentamiento", back_populates="entidad")


class Asentamiento(Base):
    __tablename__ = "asentamiento"

    id_asen  = Column(Integer,    primary_key=True, index=True)
    id_mun   = Column(Integer,    nullable=False)
    nom_mun  = Column(String(200), nullable=False)
    id_col   = Column(Integer)
    nom_col  = Column(String(200), nullable=False)
    cp_asen  = Column(String(5),  nullable=False)
    id_ent   = Column(Integer,    ForeignKey("entidad_federativa.id_ent"), nullable=False)

    entidad     = relationship("EntidadFederativa", back_populates="asentamientos")
    direcciones = relationship("Direccion",          back_populates="asentamiento")


class Direccion(Base):
    __tablename__ = "direccion"

    id_dir     = Column(Integer,     primary_key=True, index=True)
    calle_dir  = Column(String(200), nullable=False)
    no_int_dir = Column(String(200))
    no_ext_dir = Column(String(200))
    id_asen    = Column(Integer,     ForeignKey("asentamiento.id_asen"), nullable=False)
    ref_dir    = Column(String(200))

    asentamiento = relationship("Asentamiento", back_populates="direcciones")


# ---------------------------------------------------------------------------
# Catálogos de soporte (referenciados por las tablas de NNA)
# ---------------------------------------------------------------------------

class CatSexo(Base):
    __tablename__ = "cat_sexo"

    id_sexo = Column(Integer,    primary_key=True, index=True)
    nombre  = Column(String(50), nullable=False)


class CatNacionalidad(Base):
    __tablename__ = "cat_nacionalidad"

    id_nac = Column(Integer,     primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)


class CatTipoContacto(Base):
    __tablename__ = "cat_tipo_contacto"

    id_tipo_con = Column(Integer,     primary_key=True, index=True)
    nombre      = Column(String(100), nullable=False)


class CatLengua(Base):
    __tablename__ = "cat_lengua"

    id_len      = Column(Integer,     primary_key=True, index=True)
    nombre      = Column(String(100), nullable=False)
    es_indigena = Column(Boolean,     default=True)


class CatNivelCompetenciaOral(Base):
    __tablename__ = "cat_nivel_competencia_oral"

    id_niv_com  = Column(Integer,     primary_key=True, index=True)
    descripcion = Column(String(100), nullable=False)


class CatModoAdquisicionLengua(Base):
    __tablename__ = "cat_modo_adquisicion_lengua"

    id_mod_adc  = Column(Integer,     primary_key=True, index=True)
    descripcion = Column(String(100), nullable=False)


class CatDiscapacidad(Base):
    __tablename__ = "cat_discapacidad"

    id_dis = Column(Integer,     primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)


class CatGradoDependencia(Base):
    __tablename__ = "cat_grado_dependencia"

    id_gra_dep  = Column(Integer,     primary_key=True, index=True)
    descripcion = Column(String(100), nullable=False)


# ---------------------------------------------------------------------------
# Catálogos preexistentes (personal, enfermedades, lenguas INALI)
# ---------------------------------------------------------------------------

class CatRol(Base):
    __tablename__ = "cat_roles"

    id_rol     = Column(Integer,    primary_key=True, index=True)
    nombre_rol = Column(String(80), nullable=False)


class CatLenguaInali(Base):
    __tablename__ = "cat_lengua_inali"

    id_lengua   = Column(Integer,     primary_key=True, index=True)
    nombre      = Column(String(100), nullable=False)
    es_indigena = Column(Boolean,     default=True)


class CatCieSubcategoria(Base):
    __tablename__ = "cat_cie_subcategoria"

    id_subcategoria = Column(Integer,   primary_key=True, index=True)
    id_categoria    = Column(Integer,   nullable=False)
    codigo          = Column(String(7), unique=True, nullable=False)
    descripcion     = Column(String(300))
