// Manoo · dejar el conector apuntando a tu copia de la app
// ---------------------------------------------------------------------------
//   node instalar.mjs            (te dice qué va a hacer y lo hace)
//   node instalar.mjs --si       (sin preguntar)
//   MANOO_HOME=/ruta node instalar.mjs
//
// Autor: Jamiel García Velázquez · © 2026 · Todos los derechos reservados.
// ---------------------------------------------------------------------------

import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { crearInterface } from 'node:readline/promises';
import { encontrarManoo } from './index.mjs';

const AQUI = dirname(fileURLToPath(import.meta.url));
const PATCH = join(AQUI, 'cordis.patch.yml');

const ruta = encontrarManoo();
if (!ruta) {
  console.error('\n❌ No encontré la app de Manoo.\n');
  console.error('  1. Bájala en https://manoo.corporacionjamiel.workers.dev/');
  console.error('  2. Descomprímela en tu carpeta personal como «manoo»');
  console.error('  3. Vuelve a correr:  node instalar.mjs\n');
  process.exit(1);
}

console.log(`\n  Manoo está en: ${ruta}`);
console.log(`  Voy a escribir esa ruta en: ${PATCH}\n`);

if (!process.argv.includes('--si')) {
  const rl = crearInterface({ input: process.stdin, output: process.stdout });
  const respuesta = (await rl.question('  ¿Lo hago? (s/n) ')).trim().toLowerCase();
  rl.close();
  if (respuesta !== 's' && respuesta !== 'si' && respuesta !== 'sí' && respuesta !== 'y') {
    console.log('  No toqué nada.');
    process.exit(0);
  }
}

const antes = readFileSync(PATCH, 'utf8');
writeFileSync(PATCH, antes.replace(/args: \['[^']*'\]/, `args: ['${ruta}']`), 'utf8');
console.log('\n✅ Listo. Reinicia DeepSeek Harness y pídele algo como:');
console.log('     «abre el navegador y busca el clima»');
console.log('     «enséñame dónde está el botón de guardar»\n');
