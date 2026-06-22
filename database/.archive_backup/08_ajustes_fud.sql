-- ================================================================
-- Fase 1: Ajustes Críticos al FUD (Formato Único de Datos)
-- ================================================================
-- Descripción:
--   1. Agregar alias_nna a tabla NNA
--   2. Crear tabla pivote tutor_discapacidad
--   3. Crear tabla pivote personal_lengua

-- ================================================================
-- 1. ALTER TABLE nna — Agregar alias_nna
-- ================================================================
ALTER TABLE public.nna
ADD COLUMN alias_nna VARCHAR(150);

-- ================================================================
-- 2. Crear tabla pivote tutor_discapacidad
-- Relación M:N: tutor ↔ discapacidad (imitando nna_discapacidad)
-- ================================================================
CREATE TABLE public.tutor_discapacidad (
    id_tutor integer NOT NULL,
    id_dis integer NOT NULL,
    id_gra_dep integer,
    diagnost_dis boolean DEFAULT false NOT NULL,
    PRIMARY KEY (id_tutor, id_dis),
    FOREIGN KEY (id_tutor) REFERENCES public.tutor(id_tutor) ON DELETE CASCADE,
    FOREIGN KEY (id_dis) REFERENCES public.cat_discapacidad(id_dis) ON DELETE CASCADE,
    FOREIGN KEY (id_gra_dep) REFERENCES public.cat_grado_dependencia(id_gra_dep) ON DELETE SET NULL
);

ALTER TABLE public.tutor_discapacidad OWNER TO postgres;

-- ================================================================
-- 3. Crear tabla pivote personal_lengua
-- Relación M:N: personal ↔ lengua (imitando lenguaje_nna)
-- ================================================================
CREATE TABLE public.personal_lengua (
    id_personal integer NOT NULL,
    id_len integer NOT NULL,
    id_niv_com integer,
    id_mod_adc integer,
    preferente_len_personal boolean DEFAULT false NOT NULL,
    autodenom_len_personal character varying(200),
    PRIMARY KEY (id_personal, id_len),
    FOREIGN KEY (id_personal) REFERENCES public.personal(id_personal) ON DELETE CASCADE,
    FOREIGN KEY (id_len) REFERENCES public.cat_lengua(id_len) ON DELETE CASCADE,
    FOREIGN KEY (id_niv_com) REFERENCES public.cat_nivel_competencia_oral(id_niv_com) ON DELETE SET NULL,
    FOREIGN KEY (id_mod_adc) REFERENCES public.cat_modo_adquisicion_lengua(id_mod_adc) ON DELETE SET NULL
);

ALTER TABLE public.personal_lengua OWNER TO postgres;

-- ================================================================
-- Índices para optimizar búsquedas
-- ================================================================
CREATE INDEX idx_tutor_discapacidad_id_tutor ON public.tutor_discapacidad(id_tutor);
CREATE INDEX idx_tutor_discapacidad_id_dis ON public.tutor_discapacidad(id_dis);

CREATE INDEX idx_personal_lengua_id_personal ON public.personal_lengua(id_personal);
CREATE INDEX idx_personal_lengua_id_len ON public.personal_lengua(id_len);
