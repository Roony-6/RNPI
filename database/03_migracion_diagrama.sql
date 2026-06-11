-- ============================================================
-- MIGRACIÓN A 5NF SEGÚN DIAGRAMA ER — RNPI
-- Requiere: database/02_catalogos_previos.sql aplicado antes.
-- Idempotente: puede ejecutarse más de una vez sin error.
-- ============================================================

-- 0. LIMPIEZA DE LA ESTRUCTURA OBSOLETA
--    La tabla `menores` desaparece junto con sus dependientes.
--    `cat_estados`/`cat_municipios` quedan sustituidas por
--    `entidad_federativa`/`asentamiento` (datos ya migrados desde CSV).
DROP TABLE IF EXISTS apoyos_asignados CASCADE;
DROP TABLE IF EXISTS expedientes_multidisciplinarios CASCADE;
DROP TABLE IF EXISTS menor_enfermedad CASCADE;
DROP TABLE IF EXISTS menores CASCADE;
DROP TABLE IF EXISTS cat_estatus_menor CASCADE;
DROP TABLE IF EXISTS celula_integrantes CASCADE;
DROP TABLE IF EXISTS celulas CASCADE;
DROP TABLE IF EXISTS cat_municipios CASCADE;
DROP TABLE IF EXISTS cat_estados CASCADE;

-- 1. TABLAS GEOGRÁFICAS Y DOMICILIOS
CREATE TABLE IF NOT EXISTS entidad_federativa (
    id_ent SERIAL PRIMARY KEY,
    nom_ent VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS asentamiento (
    id_asen SERIAL PRIMARY KEY,
    id_mun INT NOT NULL,
    nom_mun VARCHAR(200) NOT NULL,
    id_col INT,
    nom_col VARCHAR(200) NOT NULL,
    cp_asen VARCHAR(5) NOT NULL,
    id_ent INT NOT NULL REFERENCES entidad_federativa(id_ent)
);

CREATE TABLE IF NOT EXISTS direccion (
    id_dir SERIAL PRIMARY KEY,
    calle_dir VARCHAR(200) NOT NULL,
    no_int_dir VARCHAR(200),
    no_ext_dir VARCHAR(200),
    id_asen INT NOT NULL REFERENCES asentamiento(id_asen),
    ref_dir VARCHAR(200)
);

-- 2. ENTIDADES PRINCIPALES (NNA y Tutor)
CREATE TABLE IF NOT EXISTS nna (
    id_nna SERIAL PRIMARY KEY,
    folio_nna VARCHAR(10) NOT NULL,
    nom_nna VARCHAR(200) NOT NULL,
    prim_ap_nna VARCHAR(200) NOT NULL,
    seg_ap_nna VARCHAR(200),
    nacim_nna DATE NOT NULL,
    curp_nna VARCHAR(18) UNIQUE NOT NULL,
    id_sexo INT NOT NULL REFERENCES cat_sexo(id_sexo),
    dir_actual INT REFERENCES direccion(id_dir),
    luga_nac_nna INT REFERENCES entidad_federativa(id_ent)
);

CREATE TABLE IF NOT EXISTS tutor (
    id_tutor SERIAL PRIMARY KEY,
    nom_tutor VARCHAR(200) NOT NULL,
    prim_ap_tutor VARCHAR(200) NOT NULL,
    seg_ap_tutor VARCHAR(200),
    curp_tutor VARCHAR(18) UNIQUE NOT NULL
);

-- 3. TABLAS INTERMEDIAS (Resolviendo las relaciones Muchos a Muchos)
CREATE TABLE IF NOT EXISTS nna_tutor (
    id_nna INT NOT NULL REFERENCES nna(id_nna) ON DELETE CASCADE,
    id_tutor INT NOT NULL REFERENCES tutor(id_tutor) ON DELETE CASCADE,
    PRIMARY KEY (id_nna, id_tutor)
);

CREATE TABLE IF NOT EXISTS nacionalidad_nna (
    id_nna INT NOT NULL REFERENCES nna(id_nna) ON DELETE CASCADE,
    id_nac INT NOT NULL REFERENCES cat_nacionalidad(id_nac) ON DELETE CASCADE,
    PRIMARY KEY (id_nna, id_nac)
);

CREATE TABLE IF NOT EXISTS contacto_nna (
    id_contacto SERIAL PRIMARY KEY,
    id_nna INT NOT NULL REFERENCES nna(id_nna) ON DELETE CASCADE,
    id_tipo_con INT NOT NULL REFERENCES cat_tipo_contacto(id_tipo_con),
    text_con VARCHAR(200) NOT NULL,
    desc_con VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS lenguaje_nna (
    id_nna INT NOT NULL REFERENCES nna(id_nna) ON DELETE CASCADE,
    id_len INT NOT NULL REFERENCES cat_lengua(id_len),
    id_niv_com INT REFERENCES cat_nivel_competencia_oral(id_niv_com),
    id_mod_adc INT REFERENCES cat_modo_adquisicion_lengua(id_mod_adc),
    preferente_len_nna BOOLEAN NOT NULL DEFAULT FALSE,
    autodenom_len_nna VARCHAR(200),
    PRIMARY KEY (id_nna, id_len)
);

CREATE TABLE IF NOT EXISTS nna_discapacidad (
    id_nna INT NOT NULL REFERENCES nna(id_nna) ON DELETE CASCADE,
    id_dis INT NOT NULL REFERENCES cat_discapacidad(id_dis),
    id_gra_dep INT REFERENCES cat_grado_dependencia(id_gra_dep),
    diagnost_dis BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_nna, id_dis)
);
