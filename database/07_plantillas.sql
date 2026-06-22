-- Módulo de Plantillas (equipos de trabajo multidisciplinarios)
-- RNPI — Bases de Datos, ESCOM IPN
--
-- Entidad nueva:  plantilla
-- Pivotes nuevos: plantilla_personal (equipo), nna_plantilla (historial de asignación)

-- ---------------------------------------------------------------------------
-- Plantilla (equipo de trabajo)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.plantilla (
    id_plantilla     SERIAL PRIMARY KEY,
    nombre_plantilla VARCHAR(150) NOT NULL UNIQUE,
    activa           BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------------
-- Pivote: personal que integra cada plantilla
-- Regla C (1 persona por rol, salvo Director/Coordinador) se valida en backend
-- porque el rol vive en personal.id_rol, fuera del alcance de un UNIQUE simple.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.plantilla_personal (
    id_plantilla INTEGER NOT NULL
                 REFERENCES public.plantilla(id_plantilla)
                 ON DELETE CASCADE,
    id_personal  INTEGER NOT NULL
                 REFERENCES public.personal(id_personal)
                 ON DELETE CASCADE,
    PRIMARY KEY (id_plantilla, id_personal)
);

CREATE INDEX IF NOT EXISTS idx_plantilla_personal_personal
    ON public.plantilla_personal (id_personal);

-- ---------------------------------------------------------------------------
-- Pivote histórico: plantilla asignada a cada NNA por periodo
-- id_plantilla con ON DELETE RESTRICT: el historial de asignación tiene valor
-- legal; una plantilla con historial se desactiva, no se elimina.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.nna_plantilla (
    id_nna_plantilla SERIAL PRIMARY KEY,
    id_nna           INTEGER NOT NULL
                     REFERENCES public.nna(id_nna)
                     ON DELETE CASCADE,
    id_plantilla     INTEGER NOT NULL
                     REFERENCES public.plantilla(id_plantilla)
                     ON DELETE RESTRICT,
    fecha_asignacion DATE NOT NULL DEFAULT CURRENT_DATE,
    activa           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_nna_plantilla_nna
    ON public.nna_plantilla (id_nna);

CREATE INDEX IF NOT EXISTS idx_nna_plantilla_plantilla
    ON public.nna_plantilla (id_plantilla);

-- Garantiza a nivel BD que cada NNA tenga a lo sumo una asignación activa.
CREATE UNIQUE INDEX IF NOT EXISTS uq_nna_plantilla_activa
    ON public.nna_plantilla (id_nna)
    WHERE activa;
