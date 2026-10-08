// Manoo · conector para DeepSeek Harness
// ---------------------------------------------------------------------------
// Este paquete NO trae el agente: conecta el servidor MCP de Manoo (la app, que
// se descarga aparte) con el harness, usando el puente oficial
// @deepseek-ai/dsh-mcp-client. Las herramientas aparecen como mcp__manoo__*.
//
// Si la app no está instalada, esto lo dice con palabras claras en vez de fallar
// en silencio.
//
// Autor: Jamiel García Velázquez · © 2026 · Todos los derechos reservados.
// ---------------------------------------------------------------------------

import { existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

/** Dónde suele estar la app de Manoo, y dónde se la puede pedir. */
export const RUTAS = [
  process.env.MANOO_HOME && join(process.env.MANOO_HOME, 'app', 'src', 'mcp.mjs'),
  join(homedir(), 'manoo', 'app', 'src', 'mcp.mjs'),
  join(homedir(), 'Documents', 'manoo', 'app', 'src', 'mcp.mjs'),
  '/Applications/Manoo.app/Contents/Resources/app/src/mcp.mjs',
].filter(Boolean);

export function encontrarManoo() {
  return RUTAS.find((r) => existsSync(r)) ?? null;
}

export default function manooManos() {
  const ruta = encontrarManoo();
  if (!ruta) {
    console.error(
      'Manoo: no encontré la app.\n' +
      '  1. Bájala en https://manoo.corporacionjamiel.workers.dev/ (hay prueba gratis)\n' +
      '  2. Descomprímela en tu carpeta personal como «manoo»\n' +
      '  3. Corre:  node instalar.mjs\n' +
      '  Si ya la tienes en otro lado:  MANOO_HOME=/ruta/a/manoo node instalar.mjs'
    );
  }
  return {};
}
