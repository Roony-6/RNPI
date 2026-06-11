# Catalogo de Enfermedades — CIE-10
## Red Nacional de Proteccion Infantil (RNPI)
### Bases de Datos — Prof. Ulises Velez Saldana

---

## 1. Descripcion del catalogo

### Que es el CIE-10

La Clasificacion Internacional de Enfermedades, decima revision (CIE-10) es el
estandar mundial para el registro, reporte y analisis de enfermedades, trastornos,
traumatismos y otras causas de mortalidad y morbilidad. Es publicado y mantenido
por la Organizacion Mundial de la Salud (OMS).

En Mexico, el uso del CIE-10 es obligatorio en todo el Sistema Nacional de Salud.
La Direccion General de Informacion en Salud (DGIS) de la Secretaria de Salud es
la entidad responsable de publicar y distribuir el catalogo oficial para uso en
instituciones publicas y privadas del pais. El Centro Mexicano para la Clasificacion
de Enfermedades (CEMECE) actua como el centro nacional de referencia de la OMS en
Mexico y supervisa la correcta aplicacion del catalogo.

### Por que se eligio este catalogo para el RNPI

- Es el catalogo oficial vigente de uso obligatorio en Mexico.
- Esta disponible como datos abiertos del Gobierno de Mexico, descargable sin costo.
- Cubre a cualquier persona independientemente de su condicion o derechohabiencia,
  a diferencia de los catalogos internos del IMSS o ISSSTE que solo cubren a sus
  propios afiliados.
- Permite registrar enfermedades tanto de los menores (NNA) como de sus tutores
  con un vocabulario estandarizado, evitando inconsistencias en la captura.

### Institucion responsable

- Nombre: Direccion General de Informacion en Salud (DGIS)
- Dependencia: Secretaria de Salud del Gobierno de Mexico
- Sitio oficial: https://www.gob.mx/salud/dgis
- Datos abiertos: https://datos.gob.mx

---

## 2. Estructura del catalogo

El CIE-10 tiene una jerarquia de cuatro niveles:

```
Capitulo  (22 en total)
  Bloque  (~260 en total — agrupacion por rango de codigos)
    Categoria  (~2,100 en total — codigo de 3 caracteres)
      Subcategoria  (~12,000 en total — codigo de hasta 7 caracteres)
```

Ejemplo completo descendiendo los cuatro niveles:

| Nivel       | Codigo     | Descripcion                                              |
|-------------|------------|----------------------------------------------------------|
| Capitulo    | IV         | Enfermedades endocrinas, nutricionales y metabolicas     |
| Bloque      | E10-E14    | Diabetes mellitus                                        |
| Categoria   | E11        | Diabetes mellitus tipo 2                                 |
| Subcategoria| E11.6      | Diabetes mellitus tipo 2 con otras complicaciones        |

El diagnostico en el sistema RNPI siempre se registra al nivel de subcategoria,
que es el nivel de mayor especificidad clinica.

---

## 3. Uso en el sistema RNPI

El catalogo se usa como vocabulario controlado en dos tablas del sistema:

- `menor_enfermedad` — registra los padecimientos de los NNA atendidos.
- `tutor_enfermedad` — registra los padecimientos de los tutores o responsables
  del menor, quienes en la mayoria de los casos son adultos mayores con
  enfermedades cronicas que tambien requieren atencion.

Ambas tablas almacenan ademas atributos clinicos propios del registro de la
institucion: si la enfermedad es cronica, si esta controlada, la fecha de
diagnostico y observaciones del personal.

---

## 4. Archivos incluidos en este catalogo

```
catalogo_enfermedades/
    README_catalogo_enfermedades.md   <- este archivo
    sql/
        01_crear_tablas_cie10.sql     <- DDL: crea las 4 tablas del catalogo
        02_importar_cie10.sql         <- comandos COPY para cargar los CSV
    csv/
        cie10_capitulos.csv
        cie10_bloques.csv
        cie10_categorias.csv
        cie10_subcategorias.csv
```

---

## 5. Requisitos previos

- PostgreSQL 14 o superior instalado y en ejecucion.
- Base de datos `rnpi` ya creada con el esquema base del proyecto.
- Acceso con el usuario `postgres` o un usuario con permisos de escritura
  sobre el esquema `public`.
- Los archivos CSV deben estar disponibles en la ruta que se indica al ejecutar
  los comandos (ver seccion 6).

---

## 6. Instrucciones de instalacion en Linux

### Paso 1 — Descomprimir el archivo entregado

```bash
unzip catalogo_enfermedades.zip -d catalogo_enfermedades
cd catalogo_enfermedades
```

### Paso 2 — Crear las tablas del catalogo en la base de datos

Ejecutar el script DDL que crea las cuatro tablas jerarquicas del CIE-10
y las dos tablas de relacion con menores y tutores:

```bash
sudo -u postgres psql -d rnpi -f sql/01_crear_tablas_cie10.sql
```

O usando autenticacion TCP si el sistema no permite peer authentication:

```bash
psql -h 127.0.0.1 -U postgres -d rnpi -f sql/01_crear_tablas_cie10.sql
```

### Paso 3 — Importar los datos del catalogo desde los archivos CSV

Los archivos deben cargarse en orden para respetar las llaves foraneas:
capitulos primero, subcategorias al final.

```bash
sudo -u postgres psql -d rnpi \
  -c "\copy public.cat_cie_capitulo(codigo_romano, descripcion) \
      FROM '$(pwd)/csv/cie10_capitulos.csv' CSV HEADER ENCODING 'UTF8';"

sudo -u postgres psql -d rnpi \
  -c "\copy public.cat_cie_bloque(id_capitulo, codigo_inicio, codigo_fin, descripcion) \
      FROM '$(pwd)/csv/cie10_bloques.csv' CSV HEADER ENCODING 'UTF8';"

sudo -u postgres psql -d rnpi \
  -c "\copy public.cat_cie_categoria(id_bloque, codigo, descripcion) \
      FROM '$(pwd)/csv/cie10_categorias.csv' CSV HEADER ENCODING 'UTF8';"

sudo -u postgres psql -d rnpi \
  -c "\copy public.cat_cie_subcategoria(id_categoria, codigo, descripcion) \
      FROM '$(pwd)/csv/cie10_subcategorias.csv' CSV HEADER ENCODING 'UTF8';"
```

### Paso 4 — Verificar la carga

```bash
sudo -u postgres psql -d rnpi -c "
SELECT
  (SELECT COUNT(*) FROM public.cat_cie_capitulo)    AS capitulos,
  (SELECT COUNT(*) FROM public.cat_cie_bloque)      AS bloques,
  (SELECT COUNT(*) FROM public.cat_cie_categoria)   AS categorias,
  (SELECT COUNT(*) FROM public.cat_cie_subcategoria) AS subcategorias;
"
```

Resultado esperado aproximado:

```
 capitulos | bloques | categorias | subcategorias
-----------+---------+------------+---------------
        22 |     262 |       2101 |         12420
```

### Paso 5 — Exportar un respaldo del catalogo ya cargado (opcional)

```bash
sudo -u postgres pg_dump -d rnpi \
  --table=public.cat_cie_capitulo \
  --table=public.cat_cie_bloque \
  --table=public.cat_cie_categoria \
  --table=public.cat_cie_subcategoria \
  --inserts -f respaldo_catalogo_cie10.sql
```

---

## 7. Script DDL de referencia

El archivo `sql/01_crear_tablas_cie10.sql` contiene lo siguiente:

```sql
CREATE TABLE public.cat_cie_capitulo (
    id_capitulo   SERIAL PRIMARY KEY,
    codigo_romano VARCHAR(10)  NOT NULL UNIQUE,
    descripcion   VARCHAR(300) NOT NULL
);

CREATE TABLE public.cat_cie_bloque (
    id_bloque     SERIAL PRIMARY KEY,
    id_capitulo   INTEGER NOT NULL
                  REFERENCES public.cat_cie_capitulo(id_capitulo)
                  ON DELETE RESTRICT,
    codigo_inicio VARCHAR(7)   NOT NULL,
    codigo_fin    VARCHAR(7)   NOT NULL,
    descripcion   VARCHAR(300) NOT NULL
);

CREATE TABLE public.cat_cie_categoria (
    id_categoria  SERIAL PRIMARY KEY,
    id_bloque     INTEGER NOT NULL
                  REFERENCES public.cat_cie_bloque(id_bloque)
                  ON DELETE RESTRICT,
    codigo        CHAR(3)      NOT NULL UNIQUE,
    descripcion   VARCHAR(300) NOT NULL
);

CREATE TABLE public.cat_cie_subcategoria (
    id_subcategoria SERIAL PRIMARY KEY,
    id_categoria    INTEGER NOT NULL
                    REFERENCES public.cat_cie_categoria(id_categoria)
                    ON DELETE RESTRICT,
    codigo          VARCHAR(7)   NOT NULL UNIQUE,
    descripcion     VARCHAR(300) NOT NULL
);

-- Tabla de enfermedades registradas para menores (NNA)
CREATE TABLE public.menor_enfermedad (
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

-- Tabla de enfermedades registradas para tutores
CREATE TABLE public.tutor_enfermedad (
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
```

---

## 8. Fuente y licencia del catalogo

- Fuente original: Organizacion Mundial de la Salud (OMS) — CIE-10, Version 2019.
- Adaptacion para Mexico: Direccion General de Informacion en Salud (DGIS),
  Secretaria de Salud.
- Disponible en datos abiertos del Gobierno de Mexico bajo licencia de libre uso.
- URL de descarga oficial: https://datos.gob.mx/busca/dataset/catalogo-de-claves-de-
  diagnostico-cie-10

---

*Documento preparado para la entrega de la tercera iteracion del proyecto RNPI.*
*Curso: Bases de Datos — ESCOM, IPN.*
