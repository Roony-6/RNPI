// api.js — Centraliza todas las peticiones HTTP al backend RNPI.

export const API_BASE = 'http://localhost:8000';

let token = '';

export function setToken(nuevo_token) {
  token = nuevo_token || '';
}

// Si el backend responde 401 se emite 'rnpi:sesion-expirada' (auth.js la escucha)
// y se retorna null para que el llamador aborte.
export async function apiFetch(path, opts = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;
  const res = await fetch(API_BASE + path, { ...opts, headers: { ...headers, ...opts.headers } });
  if (res.status === 401) {
    window.dispatchEvent(new CustomEvent('rnpi:sesion-expirada'));
    return null;
  }
  return res;
}

export async function apiGetJson(path, por_defecto = []) {
  try {
    const res = await apiFetch(path);
    return res && res.ok ? await res.json() : por_defecto;
  } catch {
    return por_defecto;
  }
}

// --- Valoración Médica (nna_padecimiento) ---

export function buscarCie10(q) {
  return apiGetJson(`/catalogos/cie10_buscar?q=${encodeURIComponent(q)}`);
}

export function obtenerPadecimientos(id_nna) {
  return apiGetJson(`/nna/${id_nna}/padecimientos`);
}

export function guardarPadecimiento(id_nna, datos) {
  return apiFetch(`/nna/${id_nna}/padecimientos`, { method: 'POST', body: JSON.stringify(datos) });
}

// --- Situación Legal (nna_situacion_legal) ---

export function obtenerSituacionLegal(id_nna) {
  return apiGetJson(`/nna/${id_nna}/situacion_legal`);
}

export function guardarSituacionLegal(id_nna, datos) {
  return apiFetch(`/nna/${id_nna}/situacion_legal`, { method: 'POST', body: JSON.stringify(datos) });
}

export async function loginRequest(correo, contrasena) {
  const body = new URLSearchParams({ username: correo, password: contrasena });
  const res = await fetch(API_BASE + '/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => null);
    throw new Error(err && err.detail ? err.detail : 'Credenciales incorrectas');
  }
  return res.json();
}
