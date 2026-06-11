-- Catálogo de localidades: estados y municipios (INEGI)
-- Usa las tablas cat_estados y cat_municipios ya existentes en el esquema.
-- RNPI — Bases de Datos, ESCOM IPN

-- No se crean tablas nuevas; cat_estados y cat_municipios ya existen.
-- Este script solo documenta la estructura esperada:
--
-- public.cat_estados  (id_estado SERIAL PK, nombre VARCHAR(100))
-- public.cat_municipios (id_municipio SERIAL PK, id_estado INT FK, nombre VARCHAR(150))
