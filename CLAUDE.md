# Reglas Globales del Proyecto RNPI

## Stack Tecnológico
* **Backend:** Python, FastAPI, SQLAlchemy, Pydantic.
* **Base de Datos:** PostgreSQL.
* **Frontend:** HTML5, CSS y Vanilla JavaScript (ESTRICTAMENTE prohibido usar React, Angular, Vue o librerías pesadas).

## Convenciones de Código y Base de Datos
* **Nomenclatura DB:** Usa estrictamente `snake_case` para todas las tablas, columnas y atributos. Cero tolerancia al camelCase en la base de datos.
* **Modularidad Frontend:** Todo el JavaScript debe vivir en `static/js/` en archivos modulares (ej. `api.js`, `auth.js`). El archivo `index.html` solo debe contener la estructura visual.
* **Respuestas de API:** El backend siempre debe retornar JSON puro. El renderizado visual es responsabilidad exclusiva del frontend.

## Comportamiento del Agente
* Si vas a refactorizar un archivo de más de 500 líneas, planifica la estructura en tu pensamiento antes de modificar el código.
* Ejecuta scripts de inyección de datos (Python/Pandas) solo cuando la estructura SQL haya sido confirmada.
