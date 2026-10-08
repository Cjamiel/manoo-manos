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

/** En qué idioma hablarle a la persona (español, chino o inglés). */
const IDIOMA = (() => {
  const l = (process.env.LC_ALL || process.env.LANG || Intl.DateTimeFormat().resolvedOptions().locale || 'en').toLowerCase();
  if (l.startsWith('es')) return 'es';
  if (l.startsWith('zh')) return 'zh';
  return 'en';
})();
const t = (es, en, zh) => (IDIOMA === 'zh' ? zh : IDIOMA === 'es' ? es : en);

const AQUI = dirname(fileURLToPath(import.meta.url));
const PATCH = join(AQUI, 'cordis.patch.yml');

const ruta = encontrarManoo();
if (!ruta) {
  console.error(t(
    '\n❌ No encontré la app de Manoo.\n  1. Bájala en https://manoo-deepseek.corporacionjamiel.workers.dev/'
    + '\n  2. Descomprímela en tu carpeta personal como «manoo»\n  3. Vuelve a correr:  node instalar.mjs\n',
    '\n❌ I could not find the Manoo app.\n  1. Download it from https://manoo-deepseek.corporacionjamiel.workers.dev/'
    + '\n  2. Unzip it into your home folder as “manoo”\n  3. Run again:  node instalar.mjs\n',
    '\n❌ 我没找到 Manoo 程序。\n  1. 从 https://manoo-deepseek.corporacionjamiel.workers.dev/ 下载'
    + '\n  2. 解压到你的个人文件夹，命名成 manoo\n  3. 再运行一次：node instalar.mjs\n'
  ));
  process.exit(1);
}

console.log(t(`\n  Manoo está en: ${ruta}`, `\n  Manoo is at: ${ruta}`, `\n  Manoo 在这里：${ruta}`));
console.log(t(`  Voy a escribir esa ruta en: ${PATCH}\n`, `  I will write that path into: ${PATCH}\n`,
              `  我会把这个路径写进：${PATCH}\n`));

if (!process.argv.includes('--si')) {
  const rl = crearInterface({ input: process.stdin, output: process.stdout });
  const respuesta = (await rl.question(t('  ¿Lo hago? (s/n) ', '  Do it? (y/n) ', '  要现在做吗？(s/n) '))).trim().toLowerCase();
  rl.close();
  if (respuesta !== 's' && respuesta !== 'si' && respuesta !== 'sí' && respuesta !== 'y') {
    console.log(t('  No toqué nada.', '  I touched nothing.', '  我什么都没改。'));
    process.exit(0);
  }
}

const antes = readFileSync(PATCH, 'utf8');
writeFileSync(PATCH, antes.replace(/args: \['[^']*'\]/, `args: ['${ruta}']`), 'utf8');
console.log(t('\n✅ Listo. Reinicia DeepSeek Harness y pídele algo como:',
              '\n✅ Done. Restart DeepSeek Harness and ask it something like:',
              '\n✅ 好了。重启 DeepSeek Harness，然后这样问它：'));
console.log(t('     «abre el navegador y busca el clima»', '     “open the browser and look up the weather”',
              '     「打开浏览器，查一下天气」'));
console.log(t('     «enséñame dónde está el botón de guardar»', '     “teach me where the save button is”',
              '     「教我在哪里点保存」') + '\n');
