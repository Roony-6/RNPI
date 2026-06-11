-- Catálogo de lenguas indígenas INALI (68 agrupaciones + Español)
-- RNPI — Bases de Datos, ESCOM IPN

CREATE TABLE IF NOT EXISTS public.cat_lengua_inali (
    id_lengua   SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    es_indigena BOOLEAN      NOT NULL DEFAULT TRUE
);
