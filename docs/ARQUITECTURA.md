# RNPI — Arquitectura del Sistema

**Red Nacional de Protección Infantil** · Documentación técnica oficial
**Última actualización:** 2026-06-11

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
│   │   ├── core.py          # Personal, Tutor, NNA + tablas pivote
│   │   └── catalogos.py     # Geografía, catálogos cat_*, CIE-10, INALI
│   ├── schemas/
│   │   ├── personal.py      # PersonalCrear/Actualizar/Respuesta, TokenRespuesta
│   │   └── nna.py           # NnaCrear (anidado) y esquemas de respuesta
│   └── routers/
│       ├── auth.py          # POST /auth/login
│       ├── personal.py      # CRUD /personal (RBAC: solo_director)
│       ├── nna.py           # CRUD /nna (alta transaccional 5NF)
│       └── catalogos.py     # GET /catalogos/* (roles, geografía, CIE-10…)
├── static/
│   ├── index.html           # Solo estructura visual (login + SPA)
│   ├── css/styles.css
│   └── js/
│       ├── api.js           # fetch centralizado, token, evento sesión-expirada
│       ├── auth.js          # sesión localStorage, RBAC data-roles
│       └── app.js           # UI: vistas, modales, toasts, módulos NNA/Personal
├── database/                # schema.sql (dump) + migraciones numeradas 02-05
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

### 4.3 Geografía normalizada

`entidad_federativa (1) ← asentamiento (N) ← direccion (N)` — la dirección solo guarda calle/números/referencias; municipio, colonia y CP viven en `asentamiento`.

### 4.4 Catálogos

`cat_roles`, `cat_sexo`, `cat_nacionalidad`, `cat_tipo_contacto`, `cat_lengua`, `cat_nivel_competencia_oral`, `cat_modo_adquisicion_lengua`, `cat_discapacidad`, `cat_grado_dependencia`, más los catálogos externos importados: `cat_cie_subcategoria` (CIE-10) y `cat_lengua_inali`.

> ⚠️ Los `id_rol` reales de la BD viva son: 1=Abogado, 2=Director General, 3=Coordinador Estatal, 4=Médico, 5=Psicólogo, 7=Trabajador Social, 8=Voluntario. **No confiar en los INSERT de `schema.sql`** (dump desactualizado).

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
| `GET /catalogos/roles` | 🔒 | Catálogo de roles |
| `GET /catalogos/{entidades, asentamientos/{id_ent}, sexos, nacionalidades, tipos_contacto, lenguas, niveles_competencia_oral, modos_adquisicion_lengua, discapacidades, grados_dependencia}` | ⚠️ sin auth | Catálogos `{id, nombre}` |
| `GET /catalogos/cie10_comunes` · `GET /catalogos/cie10_buscar?q=` | ⚠️ sin auth | Búsqueda CIE-10 |
| `GET /health` | — | Ping a la BD |
| `GET /ui` | — | Sirve `static/index.html` |

## 7. Frontend

- **`api.js`** — única puerta de salida HTTP. `apiFetch` inyecta el token y centraliza el manejo de 401; `apiGetJson` ofrece lectura tolerante a fallos; `loginRequest` maneja el form-encoding de OAuth2.
- **`auth.js`** — ciclo de vida de la sesión (`login`, `restaurarSesion`, `cerrarSesion`) y RBAC visual (`aplicarVisibilidadPorRol`, `tieneRol`).
- **`app.js`** — lógica de UI: navegación entre vistas (`view-nna`, `view-personal`), modales, toasts, modal de confirmación reutilizable, y los dos módulos funcionales (tabla NNA con expediente integral; tabla de personal con filtro por rol). Todo dato dinámico pasa por `esc()` antes de inyectarse al DOM. Los eventos se delegan en los `tbody` (sin handlers inline).
- **`index.html`** — exclusivamente estructura: pantallas de login y principal, tablas y modales. La sección de valoración médica existe como placeholder (`data-roles="2,4"`).

## 8. Configuración y arranque

```bash
# .env (obligatorio en producción)
DATABASE_URL=postgresql://usuario:pass@localhost:5432/rnpi
SECRET_KEY=<clave-segura>
TOKEN_EXPIRE_MINUTES=480

# Arranque
pip install -r requirements.txt
python main.py            # uvicorn en 0.0.0.0:8000, reload activo
# UI: http://localhost:8000/ui   ·   Docs OpenAPI: /docs
```

Scripts de soporte en `scripts/`: `crear_admin.py` (primer usuario), `reset_pass.py`, `inyectar_catalogos_csv.py` (carga de catálogos — ejecutar solo con la estructura SQL confirmada).

---

*El diagnóstico de salud del proyecto, deuda técnica y hoja de ruta viven en [ESTADO.md](ESTADO.md).*
