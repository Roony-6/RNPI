// app.js — Lógica de UI: navegación, modales, toasts y módulos NNA / Personal.

import { apiFetch, apiGetJson } from './api.js';
import * as auth from './auth.js';

// ==========================================
// 1. UTILIDADES DE UI (vistas, modales, toasts)
// ==========================================
const $ = (id) => document.getElementById(id);

function switchView(view_name) {
  document.querySelectorAll('.view-section').forEach((el) => el.classList.remove('active'));
  document.querySelectorAll('.nav-tab').forEach((el) => el.classList.remove('active'));
  $(`view-${view_name}`).classList.add('active');
  $(`tab-${view_name}`).classList.add('active');
}

function openModal(id)  { $(id).classList.add('open'); }
function closeModal(id) { $(id).classList.remove('open'); }

function toast(msg, tipo = 'info') {
  const t = document.createElement('div');
  t.className = `toast ${tipo}`;
  t.textContent = msg;
  $('toast-container').appendChild(t);
  setTimeout(() => t.remove(), 3800);
}

function esc(s) {
  return String(s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

let confirmCallback = null;

const CONFIRM_ICONS = {
  danger:  `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6M14 11v6"/></svg>`,
  warning: `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>`,
  success: `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"/><polyline points="9 12 11 14 15 10"/></svg>`,
};

function mostrarConfirm({ icon, title, message, btnClass, btnText, callback }) {
  confirmCallback = callback;
  const icon_el = $('confirm-icon');
  icon_el.className = `confirm-icon ${icon}`;
  icon_el.innerHTML = CONFIRM_ICONS[icon] || CONFIRM_ICONS.success;
  $('confirm-title').textContent = title;
  $('confirm-message').innerHTML = message;
  const btn = $('confirm-action-btn');
  btn.className = `btn ${btnClass}`;
  btn.textContent = btnText;
  openModal('confirm-modal-overlay');
}

// ==========================================
// 2. MÓDULO NNA (estructura 5NF: nna / tutor)
// ==========================================
let NNA_REGISTROS = [];

const ICONO_VER = `<svg viewBox="0 0 20 20" fill="currentColor"><path d="M10 12.5a2.5 2.5 0 100-5 2.5 2.5 0 000 5z"/><path fill-rule="evenodd" d="M.664 10.59a1.651 1.651 0 010-1.186A10.004 10.004 0 0110 3c4.257 0 7.893 2.66 9.336 6.41.147.381.146.804 0 1.186A10.004 10.004 0 0110 17c-4.257 0-7.893-2.66-9.336-6.41zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/></svg>`;
const ICONO_EDITAR = `<svg viewBox="0 0 20 20" fill="currentColor"><path d="M5.433 13.917l1.262-3.155A4 4 0 017.58 9.42l6.92-6.918a2.121 2.121 0 013 3l-6.92 6.918c-.383.383-.84.685-1.343.886l-3.154 1.262a.5.5 0 01-.65-.65z"/><path d="M3.5 5.75c0-.69.56-1.25 1.25-1.25H10A.75.75 0 0010 3H4.75A2.75 2.75 0 002 5.75v9.5A2.75 2.75 0 004.75 18h9.5A2.75 2.75 0 0017 15.25V10a.75.75 0 00-1.5 0v5.25c0 .69-.56 1.25-1.25 1.25h-9.5c-.69 0-1.25-.56-1.25-1.25v-9.5z"/></svg>`;
const ICONO_ELIMINAR = `<svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd"/></svg>`;
const ICONO_CANDADO_CERRADO = `<svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clip-rule="evenodd"/></svg>`;
const ICONO_CANDADO_ABIERTO = `<svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M14.5 1A4.5 4.5 0 0010 5.5V9H3a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-1V5.5a3 3 0 116 0v2.75a.75.75 0 001.5 0V5.5A4.5 4.5 0 0014.5 1z" clip-rule="evenodd"/></svg>`;

function abrirFormularioNNA() {
  ['f-nna-nombre', 'f-nna-ap1', 'f-nna-ap2', 'f-nna-curp', 'f-nna-fecha',
   'f-dir-calle', 'f-dir-noext',
   'f-tutor-nombre', 'f-tutor-ap1', 'f-tutor-ap2', 'f-tutor-curp', 'f-con-texto',
  ].forEach((id) => { $(id).value = ''; });
  ['f-nna-sexo', 'f-nna-nacionalidad', 'f-nna-lugarnac', 'f-nna-lengua',
   'f-nna-discapacidad', 'f-dir-entidad', 'f-con-tipo',
  ].forEach((id) => { $(id).value = ''; });

  const asen = $('f-dir-asen');
  asen.innerHTML = '<option value="">-- Seleccione primero una Entidad --</option>';
  asen.disabled  = true;
  toggleGradoDependencia('');

  cargarCatalogosNNA();
  openModal('modal-alta-nna');
}

function toggleGradoDependencia(id_dis) {
  const sel = $('f-nna-gradodep');
  sel.disabled = !id_dis;
  if (!id_dis) sel.value = '';
}

function llenarSelect(id, datos, placeholder) {
  const sel = $(id);
  sel.innerHTML = `<option value="">${placeholder}</option>`;
  datos.forEach((d) => { sel.innerHTML += `<option value="${d.id}">${esc(d.nombre)}</option>`; });
}

async function cargarCatalogosNNA() {
  try {
    const [sexos, nacionalidades, entidades, lenguas, discapacidades, grados, tipos_contacto] =
      await Promise.all([
        apiGetJson('/catalogos/sexos'),
        apiGetJson('/catalogos/nacionalidades'),
        apiGetJson('/catalogos/entidades'),
        apiGetJson('/catalogos/lenguas'),
        apiGetJson('/catalogos/discapacidades'),
        apiGetJson('/catalogos/grados_dependencia'),
        apiGetJson('/catalogos/tipos_contacto'),
      ]);
    llenarSelect('f-nna-sexo',         sexos,          '-- Seleccione --');
    llenarSelect('f-nna-nacionalidad', nacionalidades, '-- Seleccione --');
    llenarSelect('f-nna-lugarnac',     entidades,      '-- Seleccione --');
    llenarSelect('f-nna-lengua',       lenguas,        '-- Seleccione Lengua --');
    llenarSelect('f-nna-discapacidad', discapacidades, 'Ninguna');
    llenarSelect('f-nna-gradodep',     grados,         '-- Seleccione Grado --');
    llenarSelect('f-dir-entidad',      entidades,      '-- Seleccione Entidad --');
    llenarSelect('f-con-tipo',         tipos_contacto, '-- Seleccione --');
  } catch (e) { console.error('Error cargando catálogos NNA', e); }
}

async function cargarAsentamientos(id_ent) {
  const sel = $('f-dir-asen');
  sel.innerHTML = '<option value="">-- Cargando... --</option>';
  sel.disabled  = true;
  if (!id_ent) {
    sel.innerHTML = '<option value="">-- Seleccione primero una Entidad --</option>';
    return;
  }
  try {
    const res = await apiFetch(`/catalogos/asentamientos/${id_ent}`);
    if (res && res.ok) {
      const data = await res.json();
      sel.innerHTML = '<option value="">-- Seleccione --</option>';
      data.forEach((a) => {
        sel.innerHTML += `<option value="${a.id}">${esc(a.municipio)} — ${esc(a.colonia)} (CP ${esc(a.cp)})</option>`;
      });
      sel.disabled = false;
    }
  } catch (e) { console.error('Error cargando asentamientos', e); }
}

async function cargarExpedientes() {
  const res = await apiFetch('/nna');
  if (!res || !res.ok) return;
  NNA_REGISTROS = await res.json();
  renderTablaNNA();
}

function renderTablaNNA() {
  const tbody = $('tabla-nna-body');
  if (!NNA_REGISTROS.length) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center;padding:2rem;">Sin registros de NNA en la Base de Datos</td></tr>`;
    return;
  }
  tbody.innerHTML = NNA_REGISTROS.map((n, i) => {
    const nombre  = `${n.nom_nna} ${n.prim_ap_nna} ${n.seg_ap_nna || ''}`.trim();
    const tutores = n.tutores.length
      ? n.tutores.map((t) => `${t.nom_tutor} ${t.prim_ap_tutor}`).join(', ')
      : 'Sin tutor';
    return `
    <tr>
      <td><strong>${esc(n.folio_nna)}</strong></td>
      <td>${esc(nombre)}<br><small style="color:var(--muted)">${esc(n.curp_nna)}</small></td>
      <td>${esc(tutores)}</td>
      <td><span class="badge badge-teal">${esc(n.sexo)}</span></td>
      <td>${esc(n.nacim_nna)}</td>
      <td>
        <div class="actions">
          <button class="btn-icon" title="Ver Expediente Integral" data-action="ver" data-index="${i}">${ICONO_VER}</button>
          <button class="btn-icon danger" title="Eliminar Registro" data-action="eliminar" data-index="${i}">${ICONO_ELIMINAR}</button>
        </div>
      </td>
    </tr>`;
  }).join('');
}

async function guardarExpediente() {
  const nom   = $('f-nna-nombre').value.trim();
  const ap1   = $('f-nna-ap1').value.trim();
  const curp  = $('f-nna-curp').value.trim().toUpperCase();
  const fecha = $('f-nna-fecha').value;
  const sexo  = $('f-nna-sexo').value;
  if (!nom || !ap1)       { toast('Nombre y primer apellido del NNA son obligatorios', 'error'); return; }
  if (curp.length !== 18) { toast('La CURP del NNA debe tener 18 caracteres', 'error'); return; }
  if (!fecha)             { toast('La fecha de nacimiento es obligatoria', 'error'); return; }
  if (!sexo)              { toast('Seleccione el sexo del NNA', 'error'); return; }

  const body = {
    nom_nna:        nom,
    prim_ap_nna:    ap1,
    seg_ap_nna:     $('f-nna-ap2').value.trim() || null,
    nacim_nna:      fecha,
    curp_nna:       curp,
    id_sexo:        parseInt(sexo),
    luga_nac_nna:   parseInt($('f-nna-lugarnac').value) || null,
    direccion:      null,
    tutores:        [],
    nacionalidades: [],
    contactos:      [],
    lenguas:        [],
    discapacidades: [],
  };

  const calle = $('f-dir-calle').value.trim();
  const asen  = $('f-dir-asen').value;
  if (calle && asen) {
    body.direccion = {
      calle_dir:  calle,
      no_ext_dir: $('f-dir-noext').value.trim() || null,
      id_asen:    parseInt(asen),
    };
  }

  const tutor_nom  = $('f-tutor-nombre').value.trim();
  const tutor_ap1  = $('f-tutor-ap1').value.trim();
  const tutor_curp = $('f-tutor-curp').value.trim().toUpperCase();
  if (tutor_nom || tutor_curp) {
    if (!tutor_nom || !tutor_ap1 || tutor_curp.length !== 18) {
      toast('Complete nombre, primer apellido y CURP (18 carac.) del tutor', 'error');
      return;
    }
    body.tutores.push({
      nom_tutor:     tutor_nom,
      prim_ap_tutor: tutor_ap1,
      seg_ap_tutor:  $('f-tutor-ap2').value.trim() || null,
      curp_tutor:    tutor_curp,
    });
  }

  const nac = $('f-nna-nacionalidad').value;
  if (nac) body.nacionalidades.push(parseInt(nac));

  const tipo_con = $('f-con-tipo').value;
  const text_con = $('f-con-texto').value.trim();
  if (tipo_con && text_con) body.contactos.push({ id_tipo_con: parseInt(tipo_con), text_con });

  const lengua = $('f-nna-lengua').value;
  if (lengua) body.lenguas.push({ id_len: parseInt(lengua), preferente_len_nna: true });

  const dis = $('f-nna-discapacidad').value;
  if (dis) {
    body.discapacidades.push({
      id_dis:     parseInt(dis),
      id_gra_dep: parseInt($('f-nna-gradodep').value) || null,
    });
  }

  try {
    const res = await apiFetch('/nna', { method: 'POST', body: JSON.stringify(body) });
    if (!res) return;
    if (!res.ok) {
      const err = await res.json().catch(() => null);
      toast(err && err.detail ? err.detail : 'Error al guardar el registro', 'error');
      return;
    }
    const data = await res.json();
    toast(`NNA registrado con folio ${data.folio_nna}`, 'success');
    closeModal('modal-alta-nna');
    cargarExpedientes();
  } catch (e) { toast('Error al conectar con la BD', 'error'); }
}

function verDetalleNNA(index) {
  const n   = NNA_REGISTROS[index];
  const set = (id, val) => { $(id).innerText = val || '—'; };
  set('det-nna-folio',          n.folio_nna);
  set('det-nna-nombre',         `${n.nom_nna} ${n.prim_ap_nna} ${n.seg_ap_nna || ''}`.trim());
  set('det-nna-curp',           n.curp_nna);
  set('det-nna-fecha',          n.nacim_nna);
  set('det-nna-sexo',           n.sexo);
  set('det-nna-nacionalidad',   n.nacionalidades.join(', '));
  set('det-nna-lugarnac',       n.lugar_nacimiento);
  set('det-nna-direccion',      n.direccion);
  set('det-nna-lenguas',        n.lenguas.map((l) =>
    `${l.lengua}${l.preferente_len_nna ? ' (preferente)' : ''}${l.nivel_competencia ? ' — ' + l.nivel_competencia : ''}`
  ).join('; '));
  set('det-nna-discapacidades', n.discapacidades.map((d) =>
    `${d.discapacidad}${d.grado_dependencia ? ' — ' + d.grado_dependencia : ''}`
  ).join('; '));
  set('det-tutores',            n.tutores.map((t) =>
    `${t.nom_tutor} ${t.prim_ap_tutor} ${t.seg_ap_tutor || ''} (CURP: ${t.curp_tutor})`.replace('  ', ' ')
  ).join('; '));
  set('det-contactos',          n.contactos.map((c) => `${c.tipo}: ${c.text_con}`).join('; '));
  openModal('modal-detalle-nna');
}

function confirmarEliminarNNA(index) {
  const n = NNA_REGISTROS[index];
  mostrarConfirm({
    icon: 'danger', title: 'Eliminar Registro NNA',
    message: `¿Está seguro de eliminar el expediente <strong>${esc(n.folio_nna)}</strong>? Se borrarán también sus lenguas, contactos y discapacidades asociadas.`,
    btnClass: 'btn-danger', btnText: 'Eliminar',
    callback: async () => {
      try {
        const res = await apiFetch(`/nna/${n.id_nna}`, { method: 'DELETE' });
        if (!res || !res.ok) throw new Error();
        toast('Registro NNA eliminado exitosamente', 'success');
        closeModal('confirm-modal-overlay');
        cargarExpedientes();
      } catch (e) { toast('Error al eliminar el registro', 'error'); }
    },
  });
}

// ==========================================
// 3. MÓDULO PERSONAL
// ==========================================
let ROLES = [];
let PERSONAL_ALL = [];

async function cargarRoles() {
  const res = await apiFetch('/catalogos/roles');
  if (!res || !res.ok) return;
  ROLES = await res.json();
  const sel_form   = $('f-rol');
  const sel_filter = $('filter-rol');
  ROLES.forEach((r) => {
    sel_form.innerHTML   += `<option value="${r.id_rol}">${esc(r.nombre_rol)}</option>`;
    sel_filter.innerHTML += `<option value="${r.id_rol}">${esc(r.nombre_rol)}</option>`;
  });
}

async function cargarPersonal() {
  const res = await apiFetch('/personal');
  if (!res || !res.ok) return;
  PERSONAL_ALL = await res.json();
  filtrarPersonal();
}

function filtrarPersonal() {
  const rol_id = $('filter-rol').value;
  const arr    = rol_id ? PERSONAL_ALL.filter((p) => String(p.id_rol) === rol_id) : PERSONAL_ALL;
  const tbody  = $('tbody-personal');

  if (!arr.length) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align:center;padding:2rem;">Sin registros</td></tr>`;
    return;
  }

  tbody.innerHTML = arr.map((p) => {
    const nombre_rol = ROLES.find((r) => r.id_rol == p.id_rol)?.nombre_rol || 'Rol';
    return `<tr>
      <td>${p.id_personal}</td>
      <td><strong>${esc(p.nombre_completo)}</strong></td>
      <td>${esc(p.correo)}</td>
      <td>${esc(p.rfc)}</td>
      <td><span class="badge badge-navy">${esc(nombre_rol)}</span></td>
      <td>${p.activo ? '<span class="badge badge-green">Activo</span>' : '<span class="badge badge-red">Inactivo</span>'}</td>
      <td>
        <div class="actions">
          <button class="btn-icon" title="Ver detalle" data-action="ver" data-id="${p.id_personal}">${ICONO_VER}</button>
          <button class="btn-icon" title="Editar" data-action="editar" data-id="${p.id_personal}">${ICONO_EDITAR}</button>
          <button class="btn-icon" title="${p.activo ? 'Revocar acceso' : 'Restaurar acceso'}" data-action="acceso" data-id="${p.id_personal}" data-activo="${p.activo}">
            ${p.activo ? ICONO_CANDADO_CERRADO : ICONO_CANDADO_ABIERTO}
          </button>
          <button class="btn-icon danger" title="Eliminar" data-action="eliminar" data-id="${p.id_personal}">${ICONO_ELIMINAR}</button>
        </div>
      </td>
    </tr>`;
  }).join('');
}

async function verDetallePersonal(id) {
  try {
    const res = await apiFetch(`/personal/${id}`);
    if (!res) return;
    const p = await res.json();
    const initials       = p.nombre_completo.split(' ').slice(0, 2).map((w) => w[0]).join('').toUpperCase();
    const nombre_rol_str = ROLES.find((r) => r.id_rol == p.id_rol)?.nombre_rol || 'Rol';
    $('det-avatar').textContent = initials;
    $('det-nombre').textContent = p.nombre_completo;
    $('det-badge').innerHTML    = `<span class="badge ${p.activo ? 'badge-green' : 'badge-red'}">${p.activo ? 'Activo' : 'Inactivo'}</span> <span class="badge badge-navy">${esc(nombre_rol_str)}</span>`;
    $('det-rfc').textContent    = p.rfc;
    $('det-curp').textContent   = p.curp;
    $('det-correo').textContent = p.correo;
    $('det-rol').textContent    = nombre_rol_str;
    $('det-activo').innerHTML   = p.activo ? '<span class="badge badge-green">Activo</span>' : '<span class="badge badge-red">Inactivo</span>';
    $('det-id').textContent     = `#${p.id_personal}`;
    openModal('modal-detalle-personal');
  } catch (e) { toast('Error al cargar detalle', 'error'); }
}

function openModalNuevoPersonal() {
  ['f-id', 'f-nombre', 'f-rfc', 'f-curp', 'f-correo', 'f-rol'].forEach((id) => { $(id).value = ''; });
  $('wrap-password').style.display  = '';
  $('wrap-password2').style.display = '';
  $('modal-pers-title').innerText   = 'Registrar Personal';
  openModal('modal-form-personal');
}

function openModalEditarPersonal(id) {
  const p = PERSONAL_ALL.find((x) => x.id_personal === id);
  if (!p) return;
  $('f-id').value     = p.id_personal;
  $('f-nombre').value = p.nombre_completo;
  $('f-rfc').value    = p.rfc;
  $('f-curp').value   = p.curp;
  $('f-correo').value = p.correo;
  $('f-rol').value    = p.id_rol;
  $('wrap-password').style.display  = 'none';
  $('wrap-password2').style.display = 'none';
  $('modal-pers-title').innerText   = 'Editar Personal';
  openModal('modal-form-personal');
}

async function guardarPersonal() {
  const id   = $('f-id').value;
  const body = {
    nombre_completo: $('f-nombre').value,
    rfc:    $('f-rfc').value,
    curp:   $('f-curp').value,
    correo: $('f-correo').value,
    id_rol: Number($('f-rol').value),
  };
  if (!id) body.contrasena = $('f-password').value;

  const method = id ? 'PUT' : 'POST';
  const url    = id ? `/personal/${id}` : '/personal';
  try {
    const res = await apiFetch(url, { method, body: JSON.stringify(body) });
    if (!res || !res.ok) throw new Error('Error al guardar');
    toast('Personal guardado exitosamente', 'success');
    closeModal('modal-form-personal');
    cargarPersonal();
  } catch (e) { toast('Error de validación', 'error'); }
}

function confirmarAcceso(id, activo) {
  const p      = PERSONAL_ALL.find((x) => x.id_personal === id);
  const nombre = p ? p.nombre_completo : `#${id}`;
  if (activo) {
    mostrarConfirm({
      icon: 'warning', title: 'Revocar acceso',
      message: `¿Desea revocar el acceso al sistema de <strong>${esc(nombre)}</strong>? El registro se conservará pero no podrá iniciar sesión.`,
      btnClass: 'btn-warning', btnText: 'Revocar acceso',
      callback: () => toggleAcceso(id, false),
    });
  } else {
    mostrarConfirm({
      icon: 'success', title: 'Restaurar acceso',
      message: `¿Desea restaurar el acceso de <strong>${esc(nombre)}</strong>?`,
      btnClass: 'btn-success', btnText: 'Restaurar acceso',
      callback: () => toggleAcceso(id, true),
    });
  }
}

async function toggleAcceso(id, nuevo_activo) {
  try {
    const res = await apiFetch(`/personal/${id}/acceso`, { method: 'PATCH', body: JSON.stringify({ activo: nuevo_activo }) });
    if (!res || !res.ok) throw new Error('Error al cambiar acceso');
    toast(nuevo_activo ? 'Acceso restaurado' : 'Acceso revocado', 'info');
    closeModal('confirm-modal-overlay');
    cargarPersonal();
  } catch (e) { toast('Error de conexión', 'error'); }
}

function confirmarEliminarPersonal(id) {
  const p      = PERSONAL_ALL.find((x) => x.id_personal === id);
  const nombre = p ? p.nombre_completo : `#${id}`;
  mostrarConfirm({
    icon: 'danger', title: 'Eliminar registro de personal',
    message: `¿Está seguro de eliminar a <strong>${esc(nombre)}</strong>? Esta acción es irreversible.`,
    btnClass: 'btn-danger', btnText: 'Eliminar Personal',
    callback: () => eliminarPersonal(id),
  });
}

async function eliminarPersonal(id) {
  try {
    const res = await apiFetch(`/personal/${id}`, { method: 'DELETE' });
    if (!res || !res.ok) throw new Error('Error al eliminar');
    toast('Registro eliminado exitosamente', 'success');
    closeModal('confirm-modal-overlay');
    cargarPersonal();
  } catch (e) { toast('Error de conexión', 'error'); }
}

// ==========================================
// 4. SESIÓN Y ARRANQUE
// ==========================================
async function manejarLogin() {
  const correo = $('l-correo').value.trim();
  const pass   = $('l-pass').value;
  const error_el = $('login-error');
  if (!correo || !pass) {
    error_el.style.display = 'block';
    error_el.innerText = 'Llene los campos';
    return;
  }
  try {
    await auth.login(correo, pass);
    error_el.style.display = 'none';
    iniciarApp();
  } catch (e) {
    error_el.style.display = 'block';
    error_el.innerText = e.message;
  }
}

function manejarLogout() {
  auth.cerrarSesion();
  $('screen-main').style.display  = 'none';
  $('screen-login').style.display = 'flex';
}

function iniciarApp() {
  const usuario = auth.getUsuario();
  $('screen-login').style.display = 'none';
  $('screen-main').style.display  = 'block';
  $('header-username').textContent = usuario ? usuario.nombre_completo : 'Usuario';

  // Muestra/oculta secciones marcadas con data-roles según el id_rol del token
  auth.aplicarVisibilidadPorRol();

  cargarCatalogosNNA();
  cargarExpedientes();
  cargarRoles();
  cargarPersonal();
}

function wireEventos() {
  // Login
  $('btn-login').addEventListener('click', manejarLogin);
  $('l-pass').addEventListener('keydown', (e) => { if (e.key === 'Enter') manejarLogin(); });
  $('btn-logout').addEventListener('click', manejarLogout);
  window.addEventListener('rnpi:sesion-expirada', manejarLogout);

  // Navegación entre vistas
  document.querySelectorAll('.nav-tab[data-view]').forEach((tab) => {
    tab.addEventListener('click', () => switchView(tab.dataset.view));
  });

  // Cierre de modales: botones con data-close y clic en el fondo del overlay
  document.querySelectorAll('[data-close]').forEach((btn) => {
    btn.addEventListener('click', () => closeModal(btn.dataset.close));
  });
  document.querySelectorAll('.overlay').forEach((ov) => {
    ov.addEventListener('click', (e) => { if (e.target === ov) closeModal(ov.id); });
  });

  // Módulo NNA
  $('btn-nuevo-expediente').addEventListener('click', abrirFormularioNNA);
  $('btn-guardar-expediente').addEventListener('click', guardarExpediente);
  $('f-nna-discapacidad').addEventListener('change', (e) => toggleGradoDependencia(e.target.value));
  $('f-dir-entidad').addEventListener('change', (e) => cargarAsentamientos(e.target.value));
  $('tabla-nna-body').addEventListener('click', (e) => {
    const btn = e.target.closest('button[data-action]');
    if (!btn) return;
    const index = Number(btn.dataset.index);
    if (btn.dataset.action === 'ver')      verDetalleNNA(index);
    if (btn.dataset.action === 'eliminar') confirmarEliminarNNA(index);
  });

  // Módulo Personal
  $('btn-nuevo-personal').addEventListener('click', openModalNuevoPersonal);
  $('btn-guardar-personal').addEventListener('click', guardarPersonal);
  $('filter-rol').addEventListener('change', filtrarPersonal);
  $('tbody-personal').addEventListener('click', (e) => {
    const btn = e.target.closest('button[data-action]');
    if (!btn) return;
    const id = Number(btn.dataset.id);
    if (btn.dataset.action === 'ver')      verDetallePersonal(id);
    if (btn.dataset.action === 'editar')   openModalEditarPersonal(id);
    if (btn.dataset.action === 'acceso')   confirmarAcceso(id, btn.dataset.activo === 'true');
    if (btn.dataset.action === 'eliminar') confirmarEliminarPersonal(id);
  });

  // Modal de confirmación
  $('confirm-action-btn').addEventListener('click', () => { if (confirmCallback) confirmCallback(); });
}

document.addEventListener('DOMContentLoaded', () => {
  wireEventos();
  if (auth.restaurarSesion()) iniciarApp();
});
