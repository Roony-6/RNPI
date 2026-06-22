# RNPI — Estado del Proyecto (Diagnóstico Técnico)

**Fecha:** 2026-06-12
**Alcance:** Auditoría end-to-end sobre el repositorio (backend, frontend, SQL), actualizada tras los módulos de valoración médica / situación legal (commit `af565d9`) y el módulo de plantillas.

---

## Estado de la Arquitectura

| Capa | Tecnología | Estado |
|---|---|---|
| Backend | Python 3.14 · FastAPI 0.136 · SQLAlchemy 2.0 · Pydantic 2 | Operativo |
| Base de Datos | PostgreSQL, modelo normalizado a 5NF | Operativa (dump desactualizado) |
| Autenticación | JWT (python-jose, HS256) + bcrypt | Operativa |
| Frontend | HTML5 + CSS + Vanilla JS modular (ES Modules) | Operativo |

El modelo de datos descompone a la persona en entidades atómicas: `nna`, `tutor`, `personal` (con nombre dividido en `nom_*` / `prim_ap_*` / `seg_ap_*`), `plantilla` (equipos de trabajo), tablas pivote (`nna_tutor`, `nacionalidad_nna`, `lenguaje_nna`, `nna_discapacidad`, `contacto_nna`, `nna_padecimiento`, `nna_situacion_legal`, `plantilla_personal`, `nna_plantilla`) y catálogos de soporte (`cat_sexo`, `cat_lengua`, `cat_discapacidad`, `cat_estatus_juridico`, `cat_medida_proteccion`, geografía `entidad_federativa` → `asentamiento` → `direccion`, CIE-10, INALI).

La refactorización de campos atómicos del personal (commit `45c5b7d`, migración `database/05_personal_nombre_atomico.sql`) está **propagada de forma consistente** en las cuatro capas: modelo ORM (`app/models/core.py`), schemas Pydantic (`app/schemas/personal.py`), router (`app/routers/personal.py`) y frontend (`static/js/app.js` → `nombreCompleto()`).

---

## 🟢 Componentes Completados

- **Autenticación JWT completa**: login OAuth2 (`/auth/login`), hash bcrypt, expiración configurable (480 min), verificación de cuenta activa, dependencia `usuario_actual` reutilizable (`app/auth/security.py`).
- **RBAC en backend**: dependencia `solo_director` protege el CRUD de personal (crear, editar, activar/revocar, eliminar) verificando el nombre del rol del usuario autenticado.
- **CRUD de Personal**: alta con validación de unicidad (correo/RFC/CURP), edición, revocación/restauración de acceso (`PATCH /acceso` con protección anti auto-bloqueo) y borrado.
- **Registro transaccional de NNA en 5NF**: `POST /nna` crea en una sola transacción la dirección, el NNA, tutores (con deduplicación por CURP), nacionalidades, contactos, lenguas y discapacidades; genera folio `NNA-xxxxx` a partir del id.
- **Lectura eficiente de expedientes**: `_consulta_nna` usa `joinedload` en todas las relaciones — sin problema N+1.
- **Catálogos servidos como JSON puro**: roles, geografía en cascada (entidad → asentamiento), sexos, nacionalidades, lenguas, discapacidades, grados de dependencia, tipos de contacto y búsqueda CIE-10.
- **Frontend modular conforme a CLAUDE.md**: `index.html` solo estructura; `api.js` (fetch centralizado + token + evento `rnpi:sesion-expirada`), `auth.js` (sesión en localStorage + visibilidad por rol vía `data-roles`), `app.js` (UI, modales, toasts).
- **Mitigación XSS básica**: todo dato dinámico inyectado al DOM pasa por `esc()`.
- **Sesión persistente**: restauración desde localStorage y logout automático ante 401.
- **Valoración médica** (`POST/GET /nna/{id}/padecimientos`): diagnósticos CIE-10 por NNA con búsqueda incremental en el frontend (`data-roles="2,3,4,5"`), migración `06`.
- **Situación legal** (`POST/GET /nna/{id}/situacion_legal`): estatus jurídico + medida de protección con historial (`data-roles="1,2,3"`), migración `06`.
- **Módulo de Plantillas** (migración `07`): equipos multidisciplinarios (`plantilla`, `plantilla_personal`) y asignación histórica a NNA (`nna_plantilla`). Regla de negocio "una persona por rol" validada en backend (HTTP 400) con Director/Coordinador exentos; reasignar un NNA desactiva la asignación previa conservando el historial legal (índice único parcial en BD). UI completa para roles 2 y 3. Esto resuelve el problema de la entidad `personal` "flotante" (sin relación con los NNA que atiende).

---

## 🟡 Deuda Técnica / Advertencias

2. **RBAC desalineado entre capas.** El frontend oculta por id fijo (`data-roles="2"`), pero el backend autoriza por nombre de rol (`"director"` o `"coordinador"` en `solo_director`). Consecuencia real: un Coordinador Estatal (id 3) puede mutar personal vía API pero no ve el módulo en la UI. Un renombre de rol en BD rompería silenciosamente la autorización.
3. **Endpoints de catálogos sin autenticación.** Salvo `/catalogos/roles`, ningún endpoint de catálogos exige token (geografía, sexos, CIE-10, etc. son públicos).
4. **Dependencia sospechosa `hose==0.0.1`** en `requirements.txt` (probable typo de instalación; riesgo de typosquatting). Además `passlib` está declarado pero el código usa `bcrypt` directamente — vestigial.
5. **`folio_nna` sin constraint UNIQUE** en BD; se asigna tras un `flush` con placeholder `"PENDIENTE"`. Colisiones improbables pero posibles.
6. **Confirmación de contraseña no validada**: el modal de personal tiene campo `f-password2` (`wrap-password2`) pero `guardarPersonal()` nunca compara ambos valores.
7. **Borrado de NNA deja huérfana la fila de `direccion`** (las pivote se limpian por `ON DELETE CASCADE`, la dirección no).
8. **Token en `localStorage`**: expuesto ante cualquier XSS que evada `esc()`. Aceptable para MVP interno, no para producción.
9. **`SECRET_KEY` con default inseguro** en `app/config.py` si no existe `.env`.
10. **`apiGetJson` silencia errores** retornando el valor por defecto — fallos de catálogos pasan inadvertidos para el usuario.
11. **Manejo de errores genérico en frontend**: `guardarPersonal()` muestra "Error de validación" sin propagar el `detail` del backend (409 de correo/RFC/CURP duplicado se pierde).

---

## 🔴 Hoja de Ruta (Next Steps) — priorizada

1. **✅ COMPLETADO:** Consolidación de esquema. Se han limpiado los archivos SQL numerados (02-08) y se creó `database/01_init_schema.sql` como punto de partida único. **Alembic está configurado y sincronizado** — la BD viva ahora es el source of truth, y todas las futuras migraciones se gestionan vía `alembic revision --autogenerate`.
2. **Alinear RBAC**: definir una fuente única de verdad (ids o nombres de rol) compartida por `solo_director` y `data-roles`; exponer los permisos del usuario en la respuesta de login para que el frontend no hardcodee ids.
3. **Endpoint `PUT /nna/{id}` + UI de edición**: hoy un expediente NNA solo puede verse o eliminarse; corregir un dato exige borrar y recapturar (inaceptable para registros con folio oficial).
4. **Proteger los endpoints de catálogos** con `Depends(usuario_actual)` (incluye los nuevos `estatus_juridico` y `medidas_proteccion`).
5. **Paginación y búsqueda server-side** en `GET /nna` y `GET /personal` (hoy retornan tablas completas; no escala).
6. **Endurecimiento**: constraint UNIQUE en `folio_nna`, validación de confirmación de contraseña, eliminar `hose` y `passlib` de requirements, exigir `SECRET_KEY` por entorno (fallar al arrancar si falta en producción).
7. **Suite de pruebas** (pytest + httpx): no existe ningún test; mínimo cubrir login, RBAC de personal, el alta transaccional de NNA y la Regla C de plantillas.
8. **Edición de tutores/contactos/lenguas post-alta**: el formulario actual solo captura 1 tutor, 1 contacto, 1 lengua y 1 discapacidad aunque el modelo soporta N.
9. **UI para editar plantillas**: el backend ya expone `PUT /plantillas/{id}` (renombrar / activar-desactivar), pero el frontend aún no tiene formulario para ello.

---

*Documento generado por auditoría automatizada. Ver [ARQUITECTURA.md](ARQUITECTURA.md) para la referencia técnica del sistema.*
