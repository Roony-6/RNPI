# CONTEXTO DEL PROYECTO: RNPI (Red Nacional de Protección Infantil)

## 1. Visión General y Arquitectura
El proyecto es un sistema de gestión de expedientes multidisciplinarios para NNA (Niñas, Niños y Adolescentes). La arquitectura es cliente-servidor estricta:
* **Backend:** FastAPI (Python), SQLAlchemy (ORM), Pydantic. Todo responde exclusivamente en JSON puro.
* **Base de Datos:** PostgreSQL modelada estrictamente en 5ta Forma Normal (5NF). **Regla de oro:** Uso obligatorio de `snake_case` para todas las tablas, columnas y atributos.
* **Frontend:** Vanilla JavaScript modular (separado en `api.js`, `auth.js`, `app.js`). **Regla de oro:** Cero frameworks (ni React, ni Vue). La seguridad visual se maneja mediante atributos HTML `data-roles` alineados con los IDs reales de la base de datos.
* **Autenticación:** JWT con protección de rutas según el rol del usuario (RBAC).

## 2. Estado Actual (Lo que ya funciona)
* Las entidades principales (`nna`, `tutor`, `personal`) están normalizadas. Los nombres están divididos atómicamente (`nom_*`, `prim_ap_*`, `seg_ap_*`).
* Los módulos de expedientes incluyen catálogos de geografía, discapacidades, lenguas, situación legal y valoración médica (con búsqueda CIE-10).
* El personal (`medicos`, `abogados`, `trabajadores sociales`, etc.) ya puede iniciar sesión y ver pantallas diferenciadas.
* **El problema detectado:** La entidad `personal` está flotando. No existe relación entre quién atiende a qué menor.

## 3. Requerimientos del Nuevo Módulo: "Plantillas" (Equipos de Trabajo)
Las reglas de negocio de la fundación exigen que la atención sea mediante "Plantillas" multidisciplinarias.
* **Regla A:** El personal se agrupa en Plantillas (ej. "Plantilla Zona Norte").
* **Regla B:** A cada NNA se le asigna una Plantilla en un periodo de tiempo determinado (para mantener historial legal de quién llevó el caso).
* **Regla C (Crítica):** Una plantilla **solo puede tener a 1 persona de cada rol** (un solo médico, un solo abogado, etc.). Los roles de Director/Coordinador están exentos o no pertenecen a plantillas base.

## 4. Plan de Ejecución Solicitado
Actúa como Tech Lead y Full-Stack Developer. Trabaja de forma autónoma siguiendo estos pasos para implementar el sistema de Plantillas:

### Fase 1: Base de Datos (SQL)
Crea el archivo `database/07_plantillas.sql` con las siguientes tablas (aplica `ON DELETE CASCADE` donde corresponda):
* `plantilla`: `id_plantilla`, `nombre_plantilla`, `activa` (boolean).
* `plantilla_personal`: Tabla pivote (`id_plantilla`, `id_personal`).
* `nna_plantilla`: Tabla pivote histórica (`id_nna`, `id_plantilla`, `fecha_asignacion`, `activa`).

### Fase 2: Backend (FastAPI)
* **Modelos:** Actualiza `app/models/core.py` para mapear las 3 nuevas tablas.
* **Esquemas:** Crea `app/schemas/plantilla.py` con las validaciones Pydantic.
* **Lógica de Negocio:** Crea `app/routers/plantillas.py`. En el método `POST` para agregar personal a una plantilla, **debes implementar la validación de la Regla C** consultando la base de datos para rechazar la petición (HTTP 400) si se intenta insertar un rol duplicado en el equipo.
* Integra el router en `main.py` protegiéndolo para que solo roles administrativos puedan modificar plantillas.

### Fase 3: Frontend (Vanilla JS)
* Diseña la UI en `static/index.html` (dentro de una sección protegida para directores) para listar, crear plantillas y asignarles personal.
* Agrega la lógica en `static/js/api.js` y `static/js/app.js` para consumir los nuevos endpoints y manejar los errores HTTP 400 (mostrando al1 usuario que no puede repetir roles).

Genera el código necesario y asegúrate de mantener la coherencia con el estilo del proyecto.