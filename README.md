# RNPI — Red Nacional de Protección Infantil

Sistema web institucional para la gestión integral de expedientes de **Niños, Niñas y Adolescentes (NNA)** en situación de vulnerabilidad. Permite registrar expedientes completos del menor (datos personales, CURP, domicilio, tutores, contactos, lenguas y discapacidades), así como administrar al **personal** de la institución (empleados y voluntarios) con autenticación por token JWT y control de acceso basado en roles (Director, Médico, Desarrollador).

La aplicación expone una API REST que retorna exclusivamente JSON; todo el renderizado visual ocurre en el navegador mediante un frontend ligero sin frameworks.

---

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Backend | Python 3.11+ · [FastAPI](https://fastapi.tiangolo.com/) |
| ORM / Validación | SQLAlchemy 2 · Pydantic 2 |
| Base de datos | PostgreSQL 16 |
| Servidor ASGI | Uvicorn |
| Autenticación | JWT (`python-jose`) · bcrypt |
| Frontend | HTML5 + CSS3 + **Vanilla JavaScript modular** (módulos ES en `static/js/`: `api.js`, `auth.js`, `app.js`) — sin React, Vue ni librerías pesadas |
| Carga de datos | Python + Pandas (inyección de catálogos CSV) |

### Modelo de datos en 5ta Forma Normal (5NF)

La base de datos está **normalizada hasta la 5ta Forma Normal (5NF)**: toda relación multivaluada del expediente (tutores, nacionalidades, contactos, lenguas, discapacidades, domicilios) vive en su propia tabla de unión, eliminando dependencias de junta y redundancia. Las convenciones son estrictas:

- Nomenclatura `snake_case` en todas las tablas, columnas y atributos (cero camelCase).
- Catálogos independientes (`cat_sexo`, `cat_lengua`, `cat_roles`, `entidad_federativa`, `asentamiento`, etc.) referenciados por llaves foráneas.

---

## Estructura del Proyecto

```
RNPI/
├── main.py                  # Punto de entrada FastAPI (CORS, routers, /ui, /health)
├── requirements.txt         # Dependencias del backend
├── env.example              # Plantilla de variables de entorno
│
├── app/                     # Código del backend
│   ├── config.py            #   Lectura de .env (DATABASE_URL, SECRET_KEY, ...)
│   ├── database.py          #   Engine y sesión de SQLAlchemy
│   ├── auth/                #   Seguridad: hash bcrypt y emisión/validación de JWT
│   ├── models/              #   Modelos SQLAlchemy (core: nna/personal · catálogos)
│   ├── schemas/             #   Esquemas Pydantic de entrada/salida
│   └── routers/             #   Endpoints: /auth, /personal, /nna, /catalogos
│
├── database/                # Scripts SQL (ejecutar en orden numérico)
│   ├── schema.sql           #   Esquema base + semillas iniciales (dump de PostgreSQL)
│   ├── 02_catalogos_previos.sql   # Catálogos requeridos como FK por la migración
│   ├── 03_migracion_diagrama.sql  # Migración a 5NF según el diagrama ER (idempotente)
│   └── 04_semillas_catalogos.sql  # Semillas de catálogos de soporte (idempotente)
│
├── scripts/                 # Utilidades de administración y carga de datos
│   ├── inyectar_catalogos_csv.py  # Inyecta CSV → catálogos (Pandas + SQLAlchemy)
│   ├── crear_admin.py             # Crea el primer usuario Director
│   └── reset_pass.py              # Restablece la contraseña de un usuario
│
├── catalogos/               # Fuentes de datos oficiales (CSV + XLSX + SQL de apoyo)
│   ├── localidades/         #   Estados y municipios/asentamientos
│   ├── lenguas/             #   Catálogo de lenguas INALI
│   └── cie10/               #   Clasificación CIE-10 (capítulos, bloques, categorías)
│
└── static/                  # Frontend (Vanilla JS modular)
    ├── index.html           #   Esqueleto HTML (sin estilos ni lógica inline)
    ├── css/styles.css       #   Hoja de estilos global
    └── js/
        ├── api.js           #   Cliente HTTP centralizado (fetch + Bearer token)
        ├── auth.js          #   Sesión, token JWT y visibilidad por id_rol
        └── app.js           #   Lógica de UI y renderizado (módulos NNA y Personal)
```

---

## Guía de Instalación

### Requisitos previos

- Python 3.11 o superior
- PostgreSQL 15 o superior

### 1. Clonar el repositorio y entrar al proyecto

```bash
git clone <url-del-repositorio> RNPI
cd RNPI
```

### 2. Crear y activar el entorno virtual

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Instalar dependencias

`pandas` no forma parte del runtime del servidor; se instala aparte porque lo requiere el script de inyección de catálogos.

```bash
pip install -r requirements.txt
pip install pandas
```

### 4. Crear la base de datos

```bash
sudo -u postgres psql
```

Dentro de la consola de PostgreSQL:

```sql
CREATE DATABASE rnpi;
CREATE USER rnpi_user WITH PASSWORD 'tu_contraseña';
GRANT ALL PRIVILEGES ON DATABASE rnpi TO rnpi_user;
\q
```

### 5. Configurar el archivo `.env`

Copia la plantilla y ajusta los valores a tu entorno:

```bash
cp env.example .env
```

Contenido del `.env`:

```env
# Cadena de conexión a PostgreSQL
DATABASE_URL=postgresql://rnpi_user:tu_contraseña@localhost:5432/rnpi

# Clave secreta para firmar los JWT
# Genera una con: python -c "import secrets; print(secrets.token_hex(32))"
SECRET_KEY=clave_larga_y_aleatoria

# Duración del token en minutos (480 = 8 horas)
TOKEN_EXPIRE_MINUTES=480
```

---

## Configuración de Datos

### 1. Ejecutar los scripts SQL (en orden)

El esquema y la migración a 5NF se aplican con `psql`, **en orden numérico**. Los scripts `02`–`04` son idempotentes (pueden re-ejecutarse sin error).

```bash
psql -U rnpi_user -d rnpi -f database/schema.sql
psql -U rnpi_user -d rnpi -f database/02_catalogos_previos.sql
psql -U rnpi_user -d rnpi -f database/03_migracion_diagrama.sql
psql -U rnpi_user -d rnpi -f database/04_semillas_catalogos.sql
```

> `03_migracion_diagrama.sql` requiere que `02_catalogos_previos.sql` haya sido aplicado antes, ya que crea llaves foráneas hacia esos catálogos.

### 2. Inyectar los catálogos desde CSV

Con la estructura SQL ya confirmada, ejecuta el script de Pandas que puebla los catálogos geográficos y de lenguas (estados, municipios/asentamientos y lenguas INALI):

```bash
python scripts/inyectar_catalogos_csv.py
```

El script es seguro de re-ejecutar: si una tabla ya contiene filas, la omite. Al finalizar ajusta las secuencias (`setval`) para que los nuevos registros no colisionen con los IDs importados.

### 3. Crear el usuario administrador inicial

```bash
python scripts/crear_admin.py
```

Esto garantiza la existencia del rol **Director** y crea el usuario:

| Campo | Valor |
|---|---|
| Correo | `director@rnpi.gob.mx` |
| Contraseña | `rnpi_secreto_123` |

> Cambia esta contraseña en cuanto entres al sistema. Si necesitas restablecer la contraseña de cualquier usuario, usa `python scripts/reset_pass.py`.

---

## Ejecución

Levanta el servidor de desarrollo con Uvicorn (recarga automática activada):

```bash
uvicorn main:app --reload --port 8000
```

o de forma equivalente:

```bash
python main.py
```

| Recurso | URL |
|---|---|
| **Frontend (interfaz web)** | <http://localhost:8000/ui> |
| Documentación interactiva (Swagger) | <http://localhost:8000/docs> |
| Estado del servicio y de la BD | <http://localhost:8000/health> |
