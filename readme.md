# Red Nacional de Protección Infantil (RNPI)
### Sistema de Gestión de Expedientes y Personal

Aplicación web institucional para la gestión de menores en situación de vulnerabilidad, personal voluntario, células de trabajo, expedientes multidisciplinarios y apoyos asignados.

---

## Stack tecnológico

- **Sistema Operativo:** Linux (Ubuntu 22.04 LTS)
- **Backend:** Python 3.11+ con FastAPI
- **ORM:** SQLAlchemy
- **Servidor ASGI:** Uvicorn
- **Base de datos:** PostgreSQL 15+
- **Frontend:** HTML5 + CSS3 + JavaScript (vanilla)
- **Autenticación:** JWT con roles
- **Hashing de contraseñas:** Passlib (bcrypt)

---

## Requisitos previos

- Python 3.11 o superior
- PostgreSQL 15 o superior
- pip

Verificar instalaciones:

```bash
python3 --version
psql --version
pip --version
```
f
---

## Instalación

### 1. Descomprimir el proyecto

Descomprime el archivo `.zip` recibido y entra a la carpeta del proyecto:

```bash
unzip rnpi.zip
cd rnpi
```

### 2. Crear y activar un entorno virtual en la raiz del proyecto

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 4. Crear la base de datos en PostgreSQL

```bash
sudo -u postgres psql
```

Dentro de la consola de PostgreSQL:

```sql
CREATE DATABASE rnpi_db;
CREATE USER rnpi_user WITH PASSWORD 'tu_contraseña';
GRANT ALL PRIVILEGES ON DATABASE rnpi_db TO rnpi_user;
\q
```

### 5. Cargar el esquema de la base de datos

```bash
psql -U rnpi_user -d rnpi_db -f schema.sql
```

---

## Configuración

Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido:

```env
DATABASE_URL=postgresql://rnpi_user:tu_contraseña@localhost:5432/rnpi_db
SECRET_KEY=clave_secreta_larga_y_aleatoria
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

---

## Ejecución

```bash
source venv/bin/activate
python main.py
```

La aplicación estará disponible en: `http://localhost:8000/ui`

La documentación de la API estará en: `http://localhost:8000/docs`



---
## Iniciar sesión 

correo:director@rnpi.gob.mx
contraseña:admin123