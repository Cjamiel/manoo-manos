# Manoo · sitio (edición DeepSeek)

Página bilingüe EN/ES en **un solo archivo autocontenido** (`index.html`): el CSS va inline,
igual que tu página original. Sin dependencias, sin build de terceros.

**© 2026 Jamiel García Velázquez. Todos los derechos reservados.**

---

## Regenerar

```bash
node build/adaptar-deepseek.mjs
```

- Lee `build/origen-claude.html` (copia intacta de tu página publicada)
- Escribe `index.html`

El script aplica **reemplazos exactos y obligatorios**: si un fragmento no aparece, o aparece
más de una vez, **truena y no escribe nada**. Así nunca se cuela un cambio a medias.

### Cuando actualices tu página de Claude

1. Descarga la nueva: `curl -fsSL https://manoo.corporacionjamiel.workers.dev -o build/origen-claude.html`
2. Corre `node build/adaptar-deepseek.mjs`
3. Si truena, algún texto cambió: ajusta la cadena correspondiente en el script

---

## Qué toca el script y qué no

**No toca:** el bloque `<style>` completo, el SVG de la mano, el layout, la tipografía
(Space Grotesk + Source Serif 4), el mecanismo bilingüe, los precios ni los enlaces de Stripe.

**Sí toca:** título y metadatos, textos del hero y las secciones, el bloque de instalación,
la franja de privacidad, la etiqueta del plan Pro + Web, las rutas de medios, los enlaces
legales y las 36 cadenas del diccionario bilingüe.

---

## Verificación

```bash
# que no falte ninguna traducción
node -e "
const h=require('fs').readFileSync('index.html','utf8');
const usadas=[...new Set([...h.matchAll(/data-i18n=\"([^\"]+)\"/g)].map(m=>m[1]))];
const b=h.slice(h.indexOf('var STRINGS = {'), h.indexOf('// Annual is the discounted'));
const def=[...new Set([...b.matchAll(/^\s{6}([A-Za-z0-9]+):\s*\{/gm)].map(m=>m[1]))];
console.log('faltan:', usadas.filter(k=>!def.includes(k)));
"

# que el HTML esté balanceado
python3 -c "
from html.parser import HTMLParser
HTMLParser().feed(open('index.html',encoding='utf-8').read()); print('ok')
"
```

---

## Publicar

Sube `index.html` y el contenido de `assets/` a tu worker de Cloudflare, en la ruta que
elijas (por ejemplo `/deepseek`). Ten en cuenta:

- El video (`assets/manoo-0.1.21-horizontal-*.mp4`) **no** está en el repo: vive en tu
  servidor. Si publicas en una ruta nueva, copia también los assets.
- Las páginas legales se enlazan a tu sitio en vivo hasta que las adaptes para DeepSeek.
- Ajusta `og:url` si publicas en una subruta.

---

## Pendientes de contenido

- [ ] Grabar el video de demostración **con DeepSeek** (el actual muestra Claude)
- [ ] Adaptar `terminos.html`, `privacidad.html` y sus versiones `-en` para nombrar a DeepSeek como destinatario
- [ ] Confirmar que Manoo funciona sobre DeepSeek (Fase 0) antes de publicar
- [ ] Eliminar del diccionario las cadenas huérfanas de la sección eliminada
      (`webTitleSec`, `webWarn`, `webStep1H/P`, `webStep2H/P`, `webStep3P`, `installDeskH/P`)
