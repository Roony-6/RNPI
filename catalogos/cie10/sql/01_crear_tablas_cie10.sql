-- Tablas jerarquicas del catalogo CIE-10
-- RNPI — Bases de Datos, ESCOM IPN

CREATE TABLE IF NOT EXISTS public.cat_cie_capitulo (
    id_capitulo   SERIAL PRIMARY KEY,
    codigo_romano VARCHAR(10)  NOT NULL UNIQUE,
    descripcion   VARCHAR(300) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.cat_cie_bloque (
    id_bloque     SERIAL PRIMARY KEY,
    id_capitulo   INTEGER NOT NULL
                  REFERENCES public.cat_cie_capitulo(id_capitulo)
                  ON DELETE RESTRICT,
    codigo_inicio VARCHAR(7)   NOT NULL,
    codigo_fin    VARCHAR(7)   NOT NULL,
    descripcion   VARCHAR(300) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.cat_cie_categoria (
    id_categoria  SERIAL PRIMARY KEY,
    id_bloque     INTEGER NOT NULL
                  REFERENCES public.cat_cie_bloque(id_bloque)
                  ON DELETE RESTRICT,
    codigo        CHAR(3)      NOT NULL UNIQUE,
    descripcion   VARCHAR(300) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.cat_cie_subcategoria (
    id_subcategoria SERIAL PRIMARY KEY,
    id_categoria    INTEGER NOT NULL
                    REFERENCES public.cat_cie_categoria(id_categoria)
                    ON DELETE RESTRICT,
    codigo          VARCHAR(7)   NOT NULL UNIQUE,
    descripcion     VARCHAR(300) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.menor_enfermedad (
    id                SERIAL PRIMARY KEY,
    id_menor          INTEGER NOT NULL
                      REFERENCES public.menores(id_menor)
                      ON DELETE CASCADE,
    id_subcategoria   INTEGER NOT NULL
                      REFERENCES public.cat_cie_subcategoria(id_subcategoria)
                      ON DELETE RESTRICT,
    es_cronica        BOOLEAN NOT NULL DEFAULT FALSE,
    esta_controlada   BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_diagnostico DATE    NOT NULL DEFAULT CURRENT_DATE,
    observaciones     TEXT
);

CREATE TABLE IF NOT EXISTS public.tutor_enfermedad (
    id                SERIAL PRIMARY KEY,
    id_tutor          INTEGER NOT NULL
                      REFERENCES public.tutores(id_tutor)
                      ON DELETE CASCADE,
    id_subcategoria   INTEGER NOT NULL
                      REFERENCES public.cat_cie_subcategoria(id_subcategoria)
                      ON DELETE RESTRICT,
    es_cronica        BOOLEAN NOT NULL DEFAULT FALSE,
    esta_controlada   BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_diagnostico DATE    NOT NULL DEFAULT CURRENT_DATE,
    observaciones     TEXT
);
