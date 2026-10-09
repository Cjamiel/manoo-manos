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

/** En qué idioma hablarle a la persona (español, chino o inglés). */
const IDIOMA = (() => {
  const l = (process.env.LC_ALL || process.env.LANG || Intl.DateTimeFormat().resolvedOptions().locale || 'en').toLowerCase();
  if (l.startsWith('es')) return 'es';
  if (l.startsWith('zh')) return 'zh';
  return 'en';
})();
/** t(español, english, 中文) */
const t = (es, en, zh) => (IDIOMA === 'zh' ? zh : IDIOMA === 'es' ? es : en);
import { homedir } from 'node:os';
import { join } from 'node:path';

/** Dónde suele estar la app de Manoo, y dónde se la puede pedir. */
export const RUTAS = [
  process.env.MANOO_HOME && join(process.env.MANOO_HOME, 'src', 'mcp.mjs'),
  process.env.MANOO_HOME && join(process.env.MANOO_HOME, 'app', 'src', 'mcp.mjs'),
  // Tal como queda al instalar con el instalador (el zip se descomprime plano).
  join(homedir(), 'manoo', 'src', 'mcp.mjs'),
  join(homedir(), 'Documents', 'manoo', 'src', 'mcp.mjs'),
  join(homedir(), 'Applications', 'manoo', 'src', 'mcp.mjs'),
  // Y tal como queda cuando se trabaja desde el repo del proyecto.
  join(homedir(), 'manoo', 'app', 'src', 'mcp.mjs'),
  join(homedir(), 'Documents', 'manoo-deepseek', 'app', 'src', 'mcp.mjs'),
  '/Applications/Manoo.app/Contents/Resources/src/mcp.mjs',
].filter(Boolean);

export function encontrarManoo() {
  // Si la persona dice dónde está (MANOO_HOME), se respeta ESA ruta y nada más: así
  // «MANOO_HOME=/no/existe» significa de verdad «aquí no hay Manoo» y no se cuela la
  // copia instalada en la carpeta personal.
  const dicho = process.env.MANOO_HOME;
  if (dicho) {
    const directo = existsSync(join(dicho, 'src', 'mcp.mjs'))
      ? join(dicho, 'src', 'mcp.mjs')
      : existsSync(join(dicho, 'mcp.mjs')) ? join(dicho, 'mcp.mjs') : null;
    return directo;
  }
  return RUTAS.find((r) => existsSync(r)) ?? null;
}

export default function manooManos() {
  const ruta = encontrarManoo();
  if (!ruta) {
    console.error(t(
      'Manoo: no encontré la app.\n' +
      '  1. Bájala en https://manoo-deepseek.corporacionjamiel.workers.dev/ (hay prueba gratis)\n' +
      '  2. Descomprímela en tu carpeta personal como «manoo»\n' +
      '  3. Corre:  node instalar.mjs\n' +
      '  Si ya la tienes en otro lado:  MANOO_HOME=/ruta/a/manoo node instalar.mjs',
      'Manoo: I could not find the app.\n' +
      '  1. Download it from https://manoo-deepseek.corporacionjamiel.workers.dev/ (there is a free trial)\n' +
      '  2. Unzip it into your home folder as “manoo”\n' +
      '  3. Run:  node instalar.mjs\n' +
      '  If it is somewhere else:  MANOO_HOME=/path/to/manoo node instalar.mjs',
      'Manoo：我没找到程序。\n' +
      '  1. 从 https://manoo-deepseek.corporacionjamiel.workers.dev/ 下载（有免费额度）\n' +
      '  2. 解压到你的个人文件夹，命名成 manoo\n' +
      '  3. 运行：node instalar.mjs\n' +
      '  如果装在别处：MANOO_HOME=/你的/manoo node instalar.mjs'
    ));
  }
  return {};
}
