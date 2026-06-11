-- Importación de estados y municipios (INEGI)
-- Ejecutar desde el directorio raiz del catálogo:
--   psql -h 127.0.0.1 -U oviveros -d rnpi -f sql/02_importar_localidades.sql

\echo 'Importando estados...'
\copy public.cat_estados(id_estado, nombre) FROM 'csv/estados.csv' CSV HEADER ENCODING 'UTF8';

SELECT setval('public.cat_estados_id_estado_seq', (SELECT MAX(id_estado) FROM public.cat_estados));

\echo 'Importando municipios...'
\copy public.cat_municipios(id_municipio, id_estado, nombre) FROM 'csv/municipios.csv' CSV HEADER ENCODING 'UTF8';

SELECT setval('public.cat_municipios_id_municipio_seq', (SELECT MAX(id_municipio) FROM public.cat_municipios));

\echo 'Verificando carga...'
SELECT COUNT(*) AS total_estados    FROM public.cat_estados;
SELECT COUNT(*) AS total_municipios FROM public.cat_municipios;

\echo 'Importación completada.'
