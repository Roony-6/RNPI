# RNPI — Arquitectura del Sistema

**Red Nacional de Protección Infantil** · Documentación técnica oficial
**Última actualización:** 2026-06-12

---

## 1. Visión general

RNPI es un sistema de gestión de expedientes de Niños, Niñas y Adolescentes (NNA) y del personal que los atiende. Sigue una arquitectura cliente-servidor estricta:

```
┌─────────────────────────┐         JSON puro          ┌──────────────────────────┐
│  Frontend (Vanilla JS)  │ ◄────── HTTP/REST ───────► │   Backend (FastAPI)      │
│  static/index.html      │      Bearer JWT            │   main.py + app/         │
│  static/js/{api,auth,   │                            │                          │
│            app}.js      │                            └───────────┬──────────────┘
└─────────────────────────┘                                        │ SQLAlchemy ORM
                                                       ┌───────────▼──────────────┐
                                                       │  PostgreSQL (5NF)        │
                                                       │  database/*.sql          │
                                                       └──────────────────────────┘
```

**Principios rectores** (ver `CLAUDE.md`):

- El backend retorna exclusivamente JSON; todo renderizado es responsabilidad del frontend.
- Frontend en Vanilla JS modular — prohibidos frameworks y librerías pesadas.
- `snake_case` estricto en tablas, columnas y atributos de la BD.

## 2. Stack tecnológico

| Componente | Tecnología | Versión |
|---|---|---|
| Lenguaje backend | Python | 3.14 |
| Framework web | FastAPI | 0.136 |
| ORM | SQLAlchemy (DeclarativeBase) | 2.0 |
| Validación | Pydantic | 2.13 |
| Base de datos | PostgreSQL (driver psycopg2) | — |
| Auth | python-jose (JWT HS256) + bcrypt | — |
| Servidor | Uvicorn | 0.49 |
| Frontend | HTML5, CSS, JavaScript (ES Modules) | — |

## 3. Estructura del repositorio

```
RNPI/
├── main.py                  # App FastAPI: CORS, static mount, routers, /health
├── app/
│   ├── config.py            # .env: DATABASE_URL, SECRET_KEY, TOKEN_MINUTES
│   ├── database.py          # engine, SessionLocal, Base, get_db()
│   ├── auth/security.py     # bcrypt, JWT, usuario_actual, solo_director
│   ├── models/
│   │   ├── core.py          # Personal, Tutor, NNA, Plantilla + tablas pivote
│   │   └── catalogos.py     # Geografía, catálogos cat_*, CIE-10, INALI, legales
│   ├── schemas/
│   │   ├── personal.py      # PersonalCrear/Actualizar/Respuesta, TokenRespuesta
│   │   ├── nna.py           # NnaCrear (anidado), padecimientos, situación legal
│   │   └── plantilla.py     # Plantillas, integrantes y asignaciones NNA
│   └── routers/
│       ├── auth.py          # POST /auth/login
│       ├── personal.py      # CRUD /personal (RBAC: solo_director)
│       ├── nna.py           # CRUD /nna + valoración médica y situación legal
│       ├── plantillas.py    # Equipos de trabajo y asignación de NNA (Regla C)
│       └── catalogos.py     # GET /catalogos/* (roles, geografía, CIE-10…)
├── static/
│   ├── index.html           # Solo estructura visual (login + SPA)
│   ├── css/styles.css
│   └── js/
│       ├── api.js           # fetch centralizado, token, evento sesión-expirada
│       ├── auth.js          # sesión localStorage, RBAC data-roles
│       └── app.js           # UI: vistas, modales, toasts, módulos NNA/Personal
├── alembic/                 # Migraciones gestionadas por Alembic
│   ├── versions/            # Cambios versionados (auto-generados + manuales)
│   ├── env.py               # Configuración: importa modelos, lee DATABASE_URL del entorno
│   └── script.py.mako       # Template para nuevas migraciones
├── alembic.ini              # Configuración Alembic (URL leída de entorno)
├── database/
│   ├── 01_init_schema.sql   # Volcado de estructura actual (punto de partida único)
│   └── .archive_backup/     # Backup de migraciones numeradas históricas (02-08)
├── catalogos/               # Fuentes CSV/SQL: CIE-10, lenguas INALI, localidades
└── scripts/                 # crear_admin.py, reset_pass.py, inyección de catálogos
```

## 4. Modelo de datos (5NF)

### 4.1 Entidades principales

- **`personal`** — usuarios del sistema. Nombre en campos atómicos: `nom_personal`, `prim_ap_personal`, `seg_ap_personal` (migración `05_personal_nombre_atomico.sql`). Únicos: `rfc`, `curp`, `correo`. FK → `cat_roles`.
- **`nna`** — expediente del menor: `folio_nna` (formato `NNA-xxxxx`, autogenerado), nombre atómico, `curp_nna` (única), `nacim_nna`, FKs a `cat_sexo`, `direccion` (dir_actual) y `entidad_federativa` (lugar de nacimiento).
- **`tutor`** — adulto responsable, deduplicado por `curp_tutor`.

### 4.2 Relaciones N:M (tablas pivote, `ON DELETE CASCADE` desde nna)

| Pivote | Relaciona | Atributos propios |
|---|---|---|
| `nna_tutor` | nna ↔ tutor | — |
| `nacionalidad_nna` | nna ↔ cat_nacionalidad | — |
| `lenguaje_nna` | nna ↔ cat_lengua | nivel de competencia oral, modo de adquisición, preferente, autodenominación |
| `nna_discapacidad` | nna ↔ cat_discapacidad | grado de dependencia, diagnóstico confirmado |
| `contacto_nna` (1:N) | nna → cat_tipo_contacto | texto y descripción del contacto |
| `nna_padecimiento` (1:N) | nna → cat_cie_subcategoria | crónico, controlado, fecha de diagnóstico, notas clínicas |
| `nna_situacion_legal` (1:N) | nna → cat_estatus_juridico (+ cat_medida_proteccion) | fecha de inicio, observaciones |
| `nna_plantilla` (1:N histórica) | nna ↔ plantilla | fecha_asignacion, activa |

### 4.3 Geografía normalizada

`entidad_federativa (1) ← asentamiento (N) ← direccion (N)` — la dirección solo guarda calle/números/referencias; municipio, colonia y CP viven en `asentamiento`.

### 4.4 Catálogos

`cat_roles`, `cat_sexo`, `cat_nacionalidad`, `cat_tipo_contacto`, `cat_lengua`, `cat_nivel_competencia_oral`, `cat_modo_adquisicion_lengua`, `cat_discapacidad`, `cat_grado_dependencia`, los catálogos legales `cat_estatus_juridico` y `cat_medida_proteccion`, más los catálogos externos importados: `cat_cie_subcategoria` (CIE-10) y `cat_lengua_inali`.

> ⚠️ Los `id_rol` reales de la BD viva son: 1=Abogado, 2=Director General, 3=Coordinador Estatal, 4=Médico, 5=Psicólogo, 7=Trabajador Social, 8=Voluntario. **No confiar en los INSERT de `schema.sql`** (dump desactualizado).

### 4.5 Plantillas (equipos de trabajo multidisciplinarios)

- **`plantilla`** — equipo de trabajo (`nombre_plantilla` único, `activa`).
- **`plantilla_personal`** — pivote plantilla ↔ personal (`ON DELETE CASCADE` en ambos lados).
- **`nna_plantilla`** — historial de asignación de plantillas a NNA. `id_nna` con `CASCADE`; `id_plantilla` con `RESTRICT` (el historial tiene valor legal: una plantilla con historial se desactiva, no se elimina). Un índice único parcial (`uq_nna_plantilla_activa`) garantiza a lo sumo una asignación activa por NNA.

**Reglas de negocio** (validadas en `app/routers/plantillas.py`):

- **Regla C**: una plantilla solo admite **una persona por rol** (HTTP 400 si se intenta duplicar). Los roles cuyo nombre contiene `director` o `coordinador` están **exentos** y pueden repetirse.
- Al asignar una plantilla a un NNA, la asignación activa anterior se **desactiva automáticamente** en la misma transacción, conservándola como historial.
- No se puede asignar una plantilla inactiva.

## 5. Autenticación y autorización

### 5.1 Flujo de tokens

1. **Login**: `POST /auth/login` (form OAuth2 `username`/`password`). Verifica bcrypt y cuenta activa; responde `{access_token, token_type, usuario}`.
2. **Emisión**: JWT HS256 con `sub` = `id_personal` y `exp` (default 480 min). Config en `app/config.py` vía `.env`.
3. **Cliente**: `auth.js` guarda token y usuario en `localStorage` (`rnpi_token`, `rnpi_user`); `api.js` adjunta `Authorization: Bearer …` a toda petición.
4. **Validación**: la dependencia `usuario_actual` (`app/auth/security.py:34`) decodifica el token, carga al usuario y exige `activo = true`.
5. **Expiración**: ante un 401, `api.js` emite el evento `rnpi:sesion-expirada`; `app.js` lo escucha y fuerza logout limpiando `localStorage`.

### 5.2 RBAC

- **Backend**: la dependencia `solo_director` (`app/auth/security.py:52`) permite la acción solo si el nombre del rol contiene `"director"` o `"coordinador"`. Protege todo el módulo de personal (alta, edición, acceso, borrado). El resto de endpoints protegidos solo exigen `usuario_actual`.
- **Frontend**: atributo `data-roles="1,2,…"` en cualquier elemento del DOM; `aplicarVisibilidadPorRol()` (`static/js/auth.js:54`) lo oculta si el `id_rol` del usuario no está en la lista. Es control de *presentación* — la seguridad real reside en el backend.

## 6. API (resumen de contratos)

Todas las respuestas son JSON puro. 🔒 = requiere Bearer token; 🔒D = además rol director/coordinador.

| Método y ruta | Auth | Descripción |
|---|---|---|
| `POST /auth/login` | — | Login OAuth2 form → token + usuario |
| `GET /personal` · `GET /personal/{id}` | 🔒 | Listado / detalle de personal |
| `POST /personal` | 🔒D | Alta (valida unicidad correo/RFC/CURP, rol existente) |
| `PUT /personal/{id}` | 🔒D | Edición (sin cambio de contraseña) |
| `PATCH /personal/{id}/acceso` | 🔒D | Activar/revocar acceso (no auto-revocable) |
| `DELETE /personal/{id}` | 🔒D | Borrado físico (no auto-eliminable) |
| `POST /nna` | 🔒 | Alta transaccional: dirección + NNA + tutores + pivotes; retorna folio |
| `GET /nna` · `GET /nna/{id}` | 🔒 | Expediente integral serializado (tutores, lenguas, etc.) |
| `DELETE /nna/{id}` | 🔒 | Borrado (pivotes por CASCADE) |
| `POST /nna/{id}/padecimientos` · `GET` | 🔒 | Valoración médica (diagnósticos CIE-10) |
| `POST /nna/{id}/situacion_legal` · `GET` | 🔒 | Situación legal (estatus jurídico + medida de protección) |
| `GET /plantillas` · `GET /plantillas/{id}` | 🔒 | Plantillas con sus integrantes |
| `POST /plantillas` · `PUT /plantillas/{id}` | 🔒D | Crear / editar plantilla (nombre único → 409) |
| `POST /plantillas/{id}/personal` | 🔒D | Agregar integrante — **Regla C**: rol duplicado → 400 |
| `DELETE /plantillas/{id}/personal/{id_personal}` | 🔒D | Quitar integrante |
| `POST /plantillas/{id}/nna` | 🔒D | Asignar NNA (desactiva la asignación previa) |
| `GET /plantillas/{id}/nna` | 🔒 | NNA activos de la plantilla |
| `GET /plantillas/nna/{id_nna}` | 🔒 | Historial de plantillas de un NNA |
| `GET /catalogos/roles` | 🔒 | Catálogo de roles |
| `GET /catalogos/{entidades, asentamientos/{id_ent}, sexos, nacionalidades, tipos_contacto, lenguas, niveles_competencia_oral, modos_adquisicion_lengua, discapacidades, grados_dependencia, estatus_juridico, medidas_proteccion}` | ⚠️ sin auth | Catálogos `{id, nombre}` |
| `GET /catalogos/cie10_comunes` · `GET /catalogos/cie10_buscar?q=` | ⚠️ sin auth | Búsqueda CIE-10 |
| `GET /health` | — | Ping a la BD |
| `GET /ui` | — | Sirve `static/index.html` |

## 7. Frontend

- **`api.js`** — única puerta de salida HTTP. `apiFetch` inyecta el token y centraliza el manejo de 401; `apiGetJson` ofrece lectura tolerante a fallos; `loginRequest` maneja el form-encoding de OAuth2.
- **`auth.js`** — ciclo de vida de la sesión (`login`, `restaurarSesion`, `cerrarSesion`) y RBAC visual (`aplicarVisibilidadPorRol`, `tieneRol`).
- **`app.js`** — lógica de UI: navegación entre vistas (`view-nna`, `view-personal`, `view-plantillas`), modales, toasts, modal de confirmación reutilizable, y los módulos funcionales: tabla NNA con expediente integral (incluye valoración médica con búsqueda CIE-10, situación legal e historial de plantillas), tabla de personal con filtro por rol, y gestión de plantillas (integrantes + asignación de NNA, propagando el `detail` de los errores 400/409 al usuario). Todo dato dinámico pasa por `esc()` antes de inyectarse al DOM. Los eventos se delegan en los `tbody` (sin handlers inline).
- **`index.html`** — exclusivamente estructura: pantallas de login y principal, tablas y modales. Secciones protegidas por rol: valoración médica (`data-roles="2,3,4,5"`), situación legal (`data-roles="1,2,3"`) y plantillas (`data-roles="2,3"`).

## 8. Configuración y arranque

### 8.1 Instalación y variables de entorno

```bash
# .env (obligatorio en producción)
DATABASE_URL=postgresql://usuario:pass@localhost:5432/rnpi
SECRET_KEY=<clave-segura>
TOKEN_EXPIRE_MINUTES=480

# Instalación
pip install -r requirements.txt
```

### 8.2 Migraciones (Alembic)

**Punto de partida:** La BD viva es el source of truth. Se capturó en `database/01_init_schema.sql` y se sincronizó con Alembic mediante `alembic stamp head`.

**Aplicar nuevas migraciones** (después de cambios en `app/models/`):

```bash
# 1. Auto-generar migración desde cambios en modelos
export DATABASE_URL="postgresql://usuario:pass@localhost/rnpi"
alembic revision --autogenerate -m "Descripción del cambio"

# 2. Revisar migración generada en alembic/versions/
# 3. Aplicar a BD
alembic upgrade head

# Verificar estado
alembic current              # Revisión actual
alembic history --verbose    # Historial completo
```

**Nota:** Toda la configuración de Alembic lee `DATABASE_URL` del entorno en `alembic/env.py`; no hardcodear URLs en `alembic.ini`.

### 8.3 Arranque del servidor

```bash
# Desarrollo
python main.py            # uvicorn en 0.0.0.0:8000, reload activo
# UI: http://localhost:8000/ui   ·   Docs OpenAPI: /docs

# Producción
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

**Scripts de soporte** en `scripts/`: `crear_admin.py` (primer usuario), `reset_pass.py`, `inyectar_catalogos_csv.py` (carga de catálogos — ejecutar después de aplicar migraciones).

---

*El diagnóstico de salud del proyecto, deuda técnica y hoja de ruta viven en [ESTADO.md](ESTADO.md).*
