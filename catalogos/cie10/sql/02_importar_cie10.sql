-- Script de importacion del catalogo CIE-10
-- Ejecutar desde el directorio raiz del catalogo:
--   psql -h 127.0.0.1 -U postgres -d rnpi -f sql/02_importar_cie10.sql
-- O con sudo:
--   sudo -u postgres psql -d rnpi -f sql/02_importar_cie10.sql

\echo 'Importando capitulos...'
\copy public.cat_cie_capitulo(id_capitulo, codigo_romano, descripcion) FROM 'csv/cie10_capitulos.csv' CSV HEADER ENCODING 'UTF8';

\echo 'Importando bloques...'
\copy public.cat_cie_bloque(id_bloque, id_capitulo, codigo_inicio, codigo_fin, descripcion) FROM 'csv/cie10_bloques.csv' CSV HEADER ENCODING 'UTF8';

\echo 'Importando categorias...'
\copy public.cat_cie_categoria(id_categoria, id_bloque, codigo, descripcion) FROM 'csv/cie10_categorias.csv' CSV HEADER ENCODING 'UTF8';

\echo 'Importando subcategorias...'
\copy public.cat_cie_subcategoria(id_subcategoria, id_categoria, codigo, descripcion) FROM 'csv/cie10_subcategorias.csv' CSV HEADER ENCODING 'UTF8';

-- Actualizar las secuencias para que los SERIAL no colisionen con los IDs importados
SELECT setval('public.cat_cie_capitulo_id_capitulo_seq',    (SELECT MAX(id_capitulo)    FROM public.cat_cie_capitulo));
SELECT setval('public.cat_cie_bloque_id_bloque_seq',        (SELECT MAX(id_bloque)      FROM public.cat_cie_bloque));
SELECT setval('public.cat_cie_categoria_id_categoria_seq',  (SELECT MAX(id_categoria)   FROM public.cat_cie_categoria));
SELECT setval('public.cat_cie_subcategoria_id_subcategoria_seq', (SELECT MAX(id_subcategoria) FROM public.cat_cie_subcategoria));

\echo 'Verificando carga...'
SELECT
  (SELECT COUNT(*) FROM public.cat_cie_capitulo)     AS capitulos,
  (SELECT COUNT(*) FROM public.cat_cie_bloque)       AS bloques,
  (SELECT COUNT(*) FROM public.cat_cie_categoria)    AS categorias,
  (SELECT COUNT(*) FROM public.cat_cie_subcategoria) AS subcategorias;

\echo 'Importacion completada.'
