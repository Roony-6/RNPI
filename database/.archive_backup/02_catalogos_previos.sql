-- Catálogos requeridos por 03_migracion_diagrama.sql como FK
-- Creados como tablas vacías listas para ser pobladas

CREATE TABLE IF NOT EXISTS cat_sexo (
    id_sexo  SERIAL PRIMARY KEY,
    nombre   VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS cat_nacionalidad (
    id_nac  SERIAL PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS cat_tipo_contacto (
    id_tipo_con  SERIAL PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS cat_lengua (
    id_len      SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    es_indigena BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS cat_nivel_competencia_oral (
    id_niv_com  SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS cat_modo_adquisicion_lengua (
    id_mod_adc  SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS cat_discapacidad (
    id_dis  SERIAL PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS cat_grado_dependencia (
    id_gra_dep  SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL
);

-- Tabla de lenguas INALI (usada por el router de catálogos existente)
CREATE TABLE IF NOT EXISTS cat_lengua_inali (
    id_lengua   SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    es_indigena BOOLEAN DEFAULT TRUE
);
