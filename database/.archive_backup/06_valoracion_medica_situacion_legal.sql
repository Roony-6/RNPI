-- Módulos de Valoración Médica y Situación Legal
-- RNPI — Bases de Datos, ESCOM IPN
--
-- Catálogos nuevos (5NF): cat_estatus_juridico, cat_medida_proteccion
-- Pivotes nuevos:         nna_padecimiento, nna_situacion_legal

-- ---------------------------------------------------------------------------
-- Catálogos de soporte legal
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.cat_estatus_juridico (
    id_est_jur  SERIAL PRIMARY KEY,
    nombre      VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.cat_medida_proteccion (
    id_med_pro  SERIAL PRIMARY KEY,
    nombre      VARCHAR(150) NOT NULL UNIQUE
);

INSERT INTO public.cat_estatus_juridico (nombre) VALUES
    ('Expediente en integración'),
    ('En proceso judicial'),
    ('Bajo tutela del Estado'),
    ('Reintegración familiar en curso'),
    ('Adopción en trámite'),
    ('Situación resuelta')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO public.cat_medida_proteccion (nombre) VALUES
    ('Acogimiento residencial'),
    ('Acogimiento familiar'),
    ('Custodia provisional'),
    ('Orden de protección'),
    ('Seguimiento por trabajo social'),
    ('Representación jurídica')
ON CONFLICT (nombre) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Pivote: valoración médica (diagnósticos CIE-10 por NNA)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.nna_padecimiento (
    id_padecimiento   SERIAL PRIMARY KEY,
    id_nna            INTEGER NOT NULL
                      REFERENCES public.nna(id_nna)
                      ON DELETE CASCADE,
    id_subcategoria   INTEGER NOT NULL
                      REFERENCES public.cat_cie_subcategoria(id_subcategoria)
                      ON DELETE RESTRICT,
    es_cronico        BOOLEAN NOT NULL DEFAULT FALSE,
    esta_controlado   BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_diagnostico DATE    NOT NULL DEFAULT CURRENT_DATE,
    notas_clinicas    TEXT
);

CREATE INDEX IF NOT EXISTS idx_nna_padecimiento_nna
    ON public.nna_padecimiento (id_nna);

-- ---------------------------------------------------------------------------
-- Pivote: situación legal (estatus jurídico + medida de protección por NNA)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.nna_situacion_legal (
    id_sit_legal   SERIAL PRIMARY KEY,
    id_nna         INTEGER NOT NULL
                   REFERENCES public.nna(id_nna)
                   ON DELETE CASCADE,
    id_est_jur     INTEGER NOT NULL
                   REFERENCES public.cat_estatus_juridico(id_est_jur)
                   ON DELETE RESTRICT,
    id_med_pro     INTEGER
                   REFERENCES public.cat_medida_proteccion(id_med_pro)
                   ON DELETE RESTRICT,
    fecha_inicio   DATE NOT NULL DEFAULT CURRENT_DATE,
    observaciones  TEXT
);

CREATE INDEX IF NOT EXISTS idx_nna_situacion_legal_nna
    ON public.nna_situacion_legal (id_nna);
