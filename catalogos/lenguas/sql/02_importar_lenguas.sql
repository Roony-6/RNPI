-- Importación del catálogo de lenguas INALI
-- Ejecutar desde el directorio raiz del catálogo:
--   psql -h 127.0.0.1 -U oviveros -d rnpi -f sql/02_importar_lenguas.sql

\echo 'Importando lenguas INALI...'
\copy public.cat_lengua_inali(id_lengua, nombre, es_indigena) FROM 'csv/lenguas_inali.csv' CSV HEADER ENCODING 'UTF8';

SELECT setval('public.cat_lengua_inali_id_lengua_seq', (SELECT MAX(id_lengua) FROM public.cat_lengua_inali));

\echo 'Verificando carga...'
SELECT COUNT(*) AS total_lenguas FROM public.cat_lengua_inali;
SELECT COUNT(*) AS indigenas FROM public.cat_lengua_inali WHERE es_indigena = TRUE;

\echo 'Importación completada.'
