from sqlalchemy import Boolean, Column, Date, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from app.database import Base


class Personal(Base):
    __tablename__ = "personal"

    id_personal      = Column(Integer,     primary_key=True, index=True)
    nom_personal     = Column(String(200), nullable=False)
    prim_ap_personal = Column(String(200), nullable=False)
    seg_ap_personal  = Column(String(200))
    rfc              = Column(String(13),  nullable=False, unique=True)
    curp             = Column(String(18),  nullable=False, unique=True)
    correo           = Column(String(150), nullable=False, unique=True)
    contrasena       = Column(String,      nullable=False)
    activo           = Column(Boolean,     default=True, nullable=False)
    id_rol           = Column(Integer,     ForeignKey("cat_roles.id_rol"), nullable=False)


class Tutor(Base):
    __tablename__ = "tutor"

    id_tutor      = Column(Integer,     primary_key=True, index=True)
    nom_tutor     = Column(String(200), nullable=False)
    prim_ap_tutor = Column(String(200), nullable=False)
    seg_ap_tutor  = Column(String(200))
    curp_tutor    = Column(String(18),  unique=True, nullable=False)

    nna_tutores = relationship("NnaTutor", back_populates="tutor")


class NNA(Base):
    __tablename__ = "nna"

    id_nna       = Column(Integer,    primary_key=True, index=True)
    folio_nna    = Column(String(10), nullable=False)
    nom_nna      = Column(String(200), nullable=False)
    prim_ap_nna  = Column(String(200), nullable=False)
    seg_ap_nna   = Column(String(200))
    nacim_nna    = Column(Date,        nullable=False)
    curp_nna     = Column(String(18),  unique=True, nullable=False)
    id_sexo      = Column(Integer,     ForeignKey("cat_sexo.id_sexo"), nullable=False)
    dir_actual   = Column(Integer,     ForeignKey("direccion.id_dir"))
    luga_nac_nna = Column(Integer,     ForeignKey("entidad_federativa.id_ent"))

    sexo             = relationship("CatSexo",          foreign_keys=[id_sexo])
    direccion_actual = relationship("Direccion",         foreign_keys=[dir_actual])
    lugar_nacimiento = relationship("EntidadFederativa", foreign_keys=[luga_nac_nna])

    nna_tutores       = relationship("NnaTutor",          back_populates="nna")
    nacionalidades    = relationship("NacionalidadNna",   back_populates="nna")
    contactos         = relationship("ContactoNna",       back_populates="nna")
    lenguas           = relationship("LenguajeNna",       back_populates="nna")
    discapacidades    = relationship("NnaDiscapacidad",   back_populates="nna")
    padecimientos     = relationship("NnaPadecimiento",   back_populates="nna")
    situaciones_legales = relationship("NnaSituacionLegal", back_populates="nna")


class NnaTutor(Base):
    __tablename__ = "nna_tutor"

    id_nna   = Column(Integer, ForeignKey("nna.id_nna",     ondelete="CASCADE"), primary_key=True)
    id_tutor = Column(Integer, ForeignKey("tutor.id_tutor", ondelete="CASCADE"), primary_key=True)

    nna   = relationship("NNA",   back_populates="nna_tutores")
    tutor = relationship("Tutor", back_populates="nna_tutores")


class NacionalidadNna(Base):
    __tablename__ = "nacionalidad_nna"

    id_nna = Column(Integer, ForeignKey("nna.id_nna",              ondelete="CASCADE"), primary_key=True)
    id_nac = Column(Integer, ForeignKey("cat_nacionalidad.id_nac", ondelete="CASCADE"), primary_key=True)

    nna         = relationship("NNA",             back_populates="nacionalidades")
    nacionalidad = relationship("CatNacionalidad")


class ContactoNna(Base):
    __tablename__ = "contacto_nna"

    id_contacto = Column(Integer,     primary_key=True, index=True)
    id_nna      = Column(Integer,     ForeignKey("nna.id_nna",                ondelete="CASCADE"), nullable=False)
    id_tipo_con = Column(Integer,     ForeignKey("cat_tipo_contacto.id_tipo_con"), nullable=False)
    text_con    = Column(String(200), nullable=False)
    desc_con    = Column(String(200))

    nna        = relationship("NNA",             back_populates="contactos")
    tipo       = relationship("CatTipoContacto")


class LenguajeNna(Base):
    __tablename__ = "lenguaje_nna"

    id_nna             = Column(Integer, ForeignKey("nna.id_nna",                              ondelete="CASCADE"), primary_key=True)
    id_len             = Column(Integer, ForeignKey("cat_lengua.id_len"),                       primary_key=True)
    id_niv_com         = Column(Integer, ForeignKey("cat_nivel_competencia_oral.id_niv_com"))
    id_mod_adc         = Column(Integer, ForeignKey("cat_modo_adquisicion_lengua.id_mod_adc"))
    preferente_len_nna = Column(Boolean, nullable=False, default=False)
    autodenom_len_nna  = Column(String(200))

    nna    = relationship("NNA",                   back_populates="lenguas")
    lengua = relationship("CatLengua")
    nivel  = relationship("CatNivelCompetenciaOral")
    modo   = relationship("CatModoAdquisicionLengua")


class NnaPadecimiento(Base):
    __tablename__ = "nna_padecimiento"

    id_padecimiento   = Column(Integer, primary_key=True, index=True)
    id_nna            = Column(Integer, ForeignKey("nna.id_nna", ondelete="CASCADE"), nullable=False)
    id_subcategoria   = Column(Integer, ForeignKey("cat_cie_subcategoria.id_subcategoria"), nullable=False)
    es_cronico        = Column(Boolean, nullable=False, default=False)
    esta_controlado   = Column(Boolean, nullable=False, default=False)
    fecha_diagnostico = Column(Date,    nullable=False)
    notas_clinicas    = Column(Text)

    nna          = relationship("NNA",               back_populates="padecimientos")
    subcategoria = relationship("CatCieSubcategoria")


class NnaSituacionLegal(Base):
    __tablename__ = "nna_situacion_legal"

    id_sit_legal  = Column(Integer, primary_key=True, index=True)
    id_nna        = Column(Integer, ForeignKey("nna.id_nna", ondelete="CASCADE"), nullable=False)
    id_est_jur    = Column(Integer, ForeignKey("cat_estatus_juridico.id_est_jur"), nullable=False)
    id_med_pro    = Column(Integer, ForeignKey("cat_medida_proteccion.id_med_pro"))
    fecha_inicio  = Column(Date,    nullable=False)
    observaciones = Column(Text)

    nna     = relationship("NNA",                 back_populates="situaciones_legales")
    estatus = relationship("CatEstatusJuridico")
    medida  = relationship("CatMedidaProteccion")


class NnaDiscapacidad(Base):
    __tablename__ = "nna_discapacidad"

    id_nna       = Column(Integer, ForeignKey("nna.id_nna",                ondelete="CASCADE"), primary_key=True)
    id_dis       = Column(Integer, ForeignKey("cat_discapacidad.id_dis"),   primary_key=True)
    id_gra_dep   = Column(Integer, ForeignKey("cat_grado_dependencia.id_gra_dep"))
    diagnost_dis = Column(Boolean, nullable=False, default=False)

    nna         = relationship("NNA",                back_populates="discapacidades")
    discapacidad = relationship("CatDiscapacidad")
    grado        = relationship("CatGradoDependencia")
