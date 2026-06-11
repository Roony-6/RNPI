// auth.js — Manejo de sesión: token, usuario actual y visibilidad por rol.
// Roles del sistema (cat_roles): 1=Abogado, 2=Director General,
// 3=Coordinador Estatal, 4=Médico, 5=Psicólogo, 7=Trabajador Social,
// 8=Voluntario.

import { setToken, loginRequest } from './api.js';

const TOKEN_KEY = 'rnpi_token';
const USER_KEY  = 'rnpi_user';

let usuario = null;

export function restaurarSesion() {
  const token = localStorage.getItem(TOKEN_KEY) || '';
  usuario = JSON.parse(localStorage.getItem(USER_KEY) || 'null');
  setToken(token);
  return Boolean(token);
}

export async function login(correo, contrasena) {
  const data = await loginRequest(correo, contrasena);
  setToken(data.access_token);
  usuario = data.usuario;
  localStorage.setItem(TOKEN_KEY, data.access_token);
  localStorage.setItem(USER_KEY, JSON.stringify(usuario));
  return usuario;
}

export function cerrarSesion() {
  setToken('');
  usuario = null;
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export function getUsuario() {
  return usuario;
}

export function getIdRol() {
  return usuario && usuario.id_rol != null ? Number(usuario.id_rol) : null;
}

export function tieneRol(...roles) {
  return roles.includes(getIdRol());
}

/**
 * Renderizado condicional por rol.
 * Cualquier elemento del DOM con data-roles="1,2" solo será visible
 * si el id_rol del usuario autenticado está en esa lista.
 * Ejemplo: <div class="section-medica" data-roles="1,2">...</div>
 */
export function aplicarVisibilidadPorRol(raiz = document) {
  const id_rol = getIdRol();
  raiz.querySelectorAll('[data-roles]').forEach((el) => {
    const permitidos = el.dataset.roles
      .split(',')
      .map((s) => Number(s.trim()))
      .filter((n) => !Number.isNaN(n));
    const visible = id_rol !== null && permitidos.includes(id_rol);
    el.style.display = visible ? '' : 'none';
  });
}
