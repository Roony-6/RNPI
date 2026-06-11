# RESTRUCTURACIÓN MODULAR — RNPI

> **Propósito de este documento:** Sirve como mapa de referencia durante la reestructuración.
> Antes de crear o mover cualquier archivo, consulta aquí la ubicación final esperada.

---

## 1. Diagnóstico del estado actual

| Problema | Archivos afectados |
|---|---|
| `main.py` es un monolito de ~670 líneas (modelos ORM, auth, schemas Pydantic y rutas mezclados) | `main.py` |
| Tres carpetas de catálogos dispersas y sin unificar | `catalogo_domicilios/`, `catalogo_enfermedades/`, `catalogo_lenguas/` |
| `catalogo_enfermedades/catalogo_enfermedades/` tiene doble anidamiento redundante | `catalogo_enfermedades/catalogo_enfermedades/` |
| Archivos Excel crudos (fuentes originales) mezclados con CSV/SQL procesados | `*.xlsx` en raíz de catálogos |
| `schema.sql` (dump de BD) en la raíz del proyecto | `schema.sql` |
| Scripts utilitarios en raíz (`crear_admin.py`, `reset_pass.py`) | ambos archivos |

---

## 2. Estructura propuesta

```
RNPI/
│
├── app/                            ← lógica Python de la aplicación
│   ├── __init__.py
│   ├── config.py                   ← DATABASE_URL, SECRET_KEY, TOKEN_MINUTES
│   ├── database.py                 ← engine, SessionLocal, Base, get_db()
│   ├── models/
│   │   ├── __init__.py
│   │   ├── catalogos.py            ← CatRol, CatLenguaInali, CatEstado,
│   │   │                              CatMunicipio, CatCieSubcategoria
│   │   └── core.py                 ← Personal, Tutor, Menor,
│   │                                  HechoVictimal, TutorEnfermedad
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── auth.py                 ← TokenRespuesta
│   │   └── personal.py             ← PersonalBase, PersonalCrear,
│   │                                  PersonalActualizar, PersonalRespuesta,
│   │                                  AccesoActualizar, RolRespuesta
│   ├── auth/
│   │   ├── __init__.py
│   │   └── security.py             ← pwd_ctx, oauth2, hash_password(),
│   │                                  verify_password(), crear_token(),
│   │                                  usuario_actual(), solo_director()
│   └── routers/
│       ├── __init__.py
│       ├── auth.py                 ← POST /auth/login
│       ├── personal.py             ← GET/POST/PUT/PATCH/DELETE /personal
│       ├── catalogos.py            ← GET /cat_roles, /catalogos/*
│       └── expedientes.py          ← POST/GET /expedientes
│
├── catalogos/                      ← datos de catálogos externos (CSV + SQL)
│   ├── cie10/
│   │   ├── csv/
│   │   │   ├── cie10_capitulos.csv
│   │   │   ├── cie10_bloques.csv
│   │   │   ├── cie10_categorias.csv
│   │   │   └── cie10_subcategorias.csv
│   │   ├── sql/
│   │   │   ├── 01_crear_tablas_cie10.sql
│   │   │   └── 02_importar_cie10.sql
│   │   └── README.md
│   ├── lenguas/
│   │   ├── csv/
│   │   │   └── lenguas_inali.csv
│   │   ├── sql/
│   │   │   ├── 01_crear_tabla_lenguas.sql
│   │   │   └── 02_importar_lenguas.sql
│   │   └── fuente/
│   │       └── LENGUA_INDIGENA_2018.xlsx
│   └── localidades/
│       ├── csv/
│       │   ├── estados.csv
│       │   └── municipios.csv
│       ├── sql/
│       │   ├── 01_crear_tabla_localidades.sql
│       │   └── 02_importar_localidades.sql
│       └── fuente/
│           └── LOCALIDADES_202604.xlsx
│
├── database/
│   └── schema.sql                  ← dump principal del esquema PostgreSQL
│
├── scripts/                        ← utilidades administrativas (no son parte del servidor)
│   ├── crear_admin.py
│   └── reset_pass.py
│
├── static/                         ← frontend web estático
│   └── index.html
│
├── main.py                         ← punto de entrada: solo crea app(), monta routers
├── requirements.txt
├── env.example
├── readme.md
└── CLAUDE.md
```

---

## 3. Plan de acción por fases

### Fase 0 — Preparación (sin tocar código)
**Objetivo:** Crear la estructura de carpetas vacía para recibir los archivos.

Carpetas nuevas a crear:
- `app/`, `app/models/`, `app/schemas/`, `app/auth/`, `app/routers/`
- `catalogos/cie10/`, `catalogos/cie10/csv/`, `catalogos/cie10/sql/`
- `catalogos/lenguas/fuente/`, `catalogos/localidades/fuente/`
- `database/`
- `scripts/`

---

### Fase 1 — Consolidar catálogos
**Objetivo:** Un único directorio `catalogos/` ordenado. Eliminar duplicados y redundancias.

| Acción | Origen | Destino |
|---|---|---|
| Mover CSVs CIE-10 | `catalogo_enfermedades/catalogo_enfermedades/csv/*.csv` | `catalogos/cie10/csv/` |
| Mover SQLs CIE-10 | `catalogo_enfermedades/catalogo_enfermedades/sql/*.sql` | `catalogos/cie10/sql/` |
| Mover README CIE-10 | `catalogo_enfermedades/catalogo_enfermedades/README_catalogo_enfermedades.md` | `catalogos/cie10/README.md` |
| Mover fuente Excel lenguas | `catalogo_lenguas/LENGUA_INDIGENA_2018.xlsx` | `catalogos/lenguas/fuente/` |
| Mover fuente Excel localidades | `catalogo_domicilios/LOCALIDADES_202604.xlsx` | `catalogos/localidades/fuente/` |
| Eliminar carpetas vacías | `catalogo_enfermedades/`, `catalogo_domicilios/`, `catalogo_lenguas/` | — |

> Los CSV y SQL de `catalogos/lenguas/` y `catalogos/localidades/` ya están en el lugar correcto; solo se les agrega la subcarpeta `fuente/`.

---

### Fase 2 — Separar el esquema SQL principal
**Objetivo:** El dump de la base de datos no debe vivir en la raíz.

| Acción | Origen | Destino |
|---|---|---|
| Mover dump SQL | `schema.sql` | `database/schema.sql` |

---

### Fase 3 — Mover scripts utilitarios
**Objetivo:** Distinguir claramente qué es el servidor y qué son herramientas de administración.

| Acción | Origen | Destino |
|---|---|---|
| Mover script | `crear_admin.py` | `scripts/crear_admin.py` |
| Mover script | `reset_pass.py` | `scripts/reset_pass.py` |

> **Nota:** Ambos scripts importan variables de entorno directamente; verificar que `load_dotenv()` siga funcionando desde la nueva ruta (puede requerir ajuste del path al `.env`).

---

### Fase 4 — Modularizar el backend Python
**Objetivo:** Descomponer `main.py` en módulos con responsabilidad única.

#### 4.1 `app/config.py`
Extraer de `main.py` las líneas 25–31:
- `DATABASE_URL`, `SECRET_KEY`, `ALGORITHM`, `TOKEN_MINUTES`

#### 4.2 `app/database.py`
Extraer de `main.py` las líneas 33–47:
- `engine`, `SessionLocal`, `Base`, `get_db()`

#### 4.3 `app/models/catalogos.py`
Extraer de `main.py` las clases:
- `CatRol`, `CatLenguaInali`, `CatEstado`, `CatMunicipio`, `CatCieSubcategoria`

#### 4.4 `app/models/core.py`
Extraer de `main.py` las clases:
- `Personal`, `Tutor`, `Menor`, `HechoVictimal`, `TutorEnfermedad`

#### 4.5 `app/schemas/personal.py`
Extraer de `main.py` las clases Pydantic:
- `PersonalBase`, `PersonalCrear`, `PersonalActualizar`, `PersonalRespuesta`
- `AccesoActualizar`, `RolRespuesta`, `TokenRespuesta`

#### 4.6 `app/schemas/auth.py`
- `TokenRespuesta` (puede quedar en `personal.py` o separarse si crece)

#### 4.7 `app/auth/security.py`
Extraer de `main.py` las líneas 167–212:
- `pwd_ctx`, `oauth2`
- `hash_password()`, `verify_password()`, `crear_token()`
- `usuario_actual()`, `solo_director()`

#### 4.8 `app/routers/auth.py`
Extraer de `main.py`:
- `POST /auth/login`

#### 4.9 `app/routers/personal.py`
Extraer de `main.py`:
- `GET /personal`, `GET /personal/{id}`, `POST /personal`
- `PUT /personal/{id}`, `PATCH /personal/{id}/acceso`, `DELETE /personal/{id}`

#### 4.10 `app/routers/catalogos.py`
Extraer de `main.py`:
- `GET /cat_roles`
- `GET /catalogos/cie10_comunes`, `GET /catalogos/cie10_buscar`
- `GET /catalogos/delitos`, `GET /catalogos/lenguas`
- `GET /catalogos/estados`, `GET /catalogos/municipios/{id_estado}`

#### 4.11 `app/routers/expedientes.py`
Extraer de `main.py`:
- `ExpedienteCrear` (schema)
- `POST /expedientes`, `GET /expedientes`

#### 4.12 Refactorizar `main.py`
Dejar solo:
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from app.routers import auth, personal, catalogos, expedientes

app = FastAPI(...)
# middlewares
# mount /static
# include_router x4
# GET / y GET /health
```

---

### Fase 5 — Verificación
**Objetivo:** Confirmar que el servidor arranca correctamente y todos los endpoints responden.

1. Ejecutar `python main.py`
2. Verificar `GET /health` → `{"estado": "ok"}`
3. Verificar `POST /auth/login` con credenciales del admin de prueba
4. Verificar `GET /catalogos/lenguas` y `GET /catalogos/estados`
5. Ejecutar un registro de expediente de prueba por la UI (`/ui`)

---

## 4. Tabla de ubicación final (referencia rápida)

| Archivo / Módulo | Ubicación final |
|---|---|
| Punto de entrada del servidor | `main.py` |
| Configuración y variables de entorno | `app/config.py` |
| Conexión a BD y sesión | `app/database.py` |
| Modelos ORM — catálogos | `app/models/catalogos.py` |
| Modelos ORM — entidades principales | `app/models/core.py` |
| Schemas Pydantic — personal y auth | `app/schemas/personal.py` |
| Autenticación (JWT, bcrypt, dependencias) | `app/auth/security.py` |
| Router autenticación | `app/routers/auth.py` |
| Router personal | `app/routers/personal.py` |
| Router catálogos | `app/routers/catalogos.py` |
| Router expedientes | `app/routers/expedientes.py` |
| Dump PostgreSQL | `database/schema.sql` |
| CSV CIE-10 | `catalogos/cie10/csv/` |
| SQL CIE-10 | `catalogos/cie10/sql/` |
| CSV Lenguas INALI | `catalogos/lenguas/csv/` |
| SQL Lenguas | `catalogos/lenguas/sql/` |
| Excel fuente Lenguas | `catalogos/lenguas/fuente/` |
| CSV Localidades | `catalogos/localidades/csv/` |
| SQL Localidades | `catalogos/localidades/sql/` |
| Excel fuente Localidades | `catalogos/localidades/fuente/` |
| Script crear admin | `scripts/crear_admin.py` |
| Script reset contraseña | `scripts/reset_pass.py` |
| Frontend HTML | `static/index.html` |
