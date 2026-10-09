#!/usr/bin/env bash
# Manoo para DeepSeek · instalador guiado (macOS)
# ---------------------------------------------------------------------------
# Uso:  curl -fsSL https://manoo-deepseek.corporacionjamiel.workers.dev/instalar.sh | bash
#
# Revisa lo que Manoo necesita, baja el programa, te guía para dar los permisos
# de macOS y para poner tu llave de DeepSeek, y al final te dice cómo empezar.
# Habla español si tu sistema está en español, inglés si no.
#
# No manda nada a ningún lado: solo baja el programa de nuestro sitio.
#
# Autor: Jamiel García Velázquez · © 2026 · Todos los derechos reservados.
# ---------------------------------------------------------------------------
set -u

SITIO="${MANOO_SITIO:-https://manoo-deepseek.corporacionjamiel.workers.dev}"
ARCHIVO="manoo-deepseek-0.1.0.zip"
VERSION="0.1.0"
DESTINO="${MANOO_DESTINO:-$HOME/manoo}"
NODE_MIN=18
NODE_VERSION=22.23.2
OK=0; FALTA=0; AVISOS=""

# --- idioma ------------------------------------------------------------------
LOC="${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}"
if [ -z "$LOC" ] && [ "$(uname -s)" = Darwin ]; then LOC="$(defaults read -g AppleLocale 2>/dev/null || true)"; fi
case "$LOC" in
  es*|ES*) IDIOMA=es ;;
  zh*|ZH*) IDIOMA=zh ;;
  *) IDIOMA=en ;;
esac
# t "español" "english" "中文" ["中文"]: en chino, si no hay traducción, se muestra el inglés.
t() {
  case "$IDIOMA" in
    zh) if [ -n "${3:-}" ]; then printf '%s' "$3"; else printf '%s' "$2"; fi ;;
    en) printf '%s' "$2" ;;
    *) printf '%s' "$1" ;;
  esac
}

# --- presentación ------------------------------------------------------------
if [ -t 1 ]; then B=$'\e[1m'; V=$'\e[32m'; R=$'\e[31m'; A=$'\e[33m'; N=$'\e[0m'; else B=""; V=""; R=""; A=""; N=""; fi
PASO=0
titulo() { PASO=$((PASO + 1)); printf '\n%s== %d. %s ==%s\n' "$B" "$PASO" "$1" "$N"; }
bien()  { printf '  %s✓%s %s\n' "$V" "$N" "$1"; OK=$((OK + 1)); }
mal()   { printf '  %s✗%s %s\n' "$R" "$N" "$1"; FALTA=$((FALTA + 1)); AVISOS="$AVISOS$'\n'  • $1"; }
aviso() { printf '  %s!%s %s\n' "$A" "$N" "$1"; }
info()  { printf '    %s\n' "$1"; }
if { : < /dev/tty; } 2>/dev/null; then TTY=1; else TTY=0; fi
preguntar() {  # responde 0 si la persona dice que sí
  local r=""
  if [ "$TTY" = 1 ]; then printf '  %s? %s [%s]: %s' "$B" "$1" "$(t S/n Y/n)" "$N" > /dev/tty; read -r r < /dev/tty || r="n"; else r="n"; fi
  case "$r" in n|N|no|NO|No) return 1 ;; *) return 0 ;; esac
}
esperar() { if [ "$TTY" = 1 ]; then printf '    %s%s%s' "$B" "$(t 'Cuando termines, presiona Enter…' 'When you are done, press Enter…' '做完后按回车…')" "$N" > /dev/tty; read -r _ < /dev/tty || true; fi; }
existe() { command -v "$1" >/dev/null 2>&1; }

printf '\n%sManoo para DeepSeek%s · %s\n' "$B" "$N" "$(t 'instalador' 'installer' "安装程序")"
printf '%s\n' "$(t 'Te voy a acompañar paso por paso. Nada se instala sin tu permiso.' 'I will walk you through it. Nothing is installed without your permission.' "我会一步一步陪着你。没有你的同意，什么都不会安装。")"

# ── 1. Sistema ───────────────────────────────────────────────────────────────
titulo "$(t 'Tu sistema' 'Your system' "你的系统")"
SO="$(uname -s)"
if [ "$SO" = Darwin ]; then
  bien "$(t 'macOS' 'macOS' "macOS") $(sw_vers -productVersion 2>/dev/null || echo)"
else
  mal "$(t 'Esta versión de Manoo es solo para macOS.' 'This version of Manoo is for macOS only.' "这个版本的 Manoo 只支持 macOS。")"
  info "$(t 'Windows y Linux vienen en el proyecto de la versión de Claude.' 'Windows and Linux are in the Claude version project.' "Windows 和 Linux 在 Claude 版本的项目里。" "Windows 和 Linux 在 Claude 版本的项目里。")"
  printf '\n%s\n' "$(t 'No puedo seguir en este sistema. No instalé nada.' 'I cannot continue on this system. I installed nothing.' "这个系统上我没法继续。我什么都没安装。")"
  exit 1
fi

# ── 2. Node ──────────────────────────────────────────────────────────────────
titulo "$(t 'Node (lo que hace correr a Manoo)' 'Node (what runs Manoo)' "Node（Manoo 运行需要它）")"
NODE_PROPIO=""
# Ojo: no basta con que exista «node». Si está en una carpeta personal, el Terminal de
# la persona puede no verlo y Manoo no abriría. Solo se acepta si está en un lugar
# estándar; si no, Manoo se lleva el suyo y así siempre funciona.
RUTA_NODE="$(command -v node 2>/dev/null || true)"
case "$RUTA_NODE" in
  /usr/bin/node|/usr/local/bin/node|/opt/homebrew/bin/node) NODE_ESTANDAR=1 ;;
  *) NODE_ESTANDAR=0 ;;
esac
if [ -n "$RUTA_NODE" ] && [ "$NODE_ESTANDAR" = 1 ] && [ "$(node -v | sed 's/^v//' | cut -d. -f1)" -ge "$NODE_MIN" ] 2>/dev/null; then
  bien "Node $(node -v)"
else
  if [ -n "$RUTA_NODE" ]; then
    info "$(t "Tu Node está en una carpeta que el Terminal no siempre ve; dejo uno dentro de Manoo para que siempre abra." "Your Node lives in a folder Terminal does not always see; I will keep one inside Manoo so it always opens." "你现有的 Node 放在终端不一定能找到的位置；我在 Manoo 里放一份，保证一定能打开。")"
  fi
  # Si no hay Node en el sistema, se baja el OFICIAL y se queda DENTRO de Manoo:
  # así nadie tiene que instalar nada ni tocar su Mac (ni Homebrew, ni permisos de
  # administrador). La licencia de Node (MIT) se guarda junto a él.
  caso="$(uname -m)"
  if [ "$caso" = arm64 ]; then PAQ="darwin-arm64"; else PAQ="darwin-x64"; fi
  URL_NODE="https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-$PAQ.tar.gz"
  if [ "$FALTA" -eq 0 ] || preguntar "$(t "No tienes Node. ¿Bajo el oficial y lo dejo dentro de Manoo? (son unos 50 MB, una sola vez)" "You do not have Node. Shall I download the official one and keep it inside Manoo? (about 50 MB, once)")"; then
    mkdir -p "$DESTINO/node"
    if curl -fsSL "$URL_NODE" -o "$DESTINO/node/node.tar.gz" 2>/dev/null; then
      tar -xzf "$DESTINO/node/node.tar.gz" -C "$DESTINO/node" --strip-components=1 2>/dev/null
      rm -f "$DESTINO/node/node.tar.gz"
      if [ -x "$DESTINO/node/bin/node" ]; then
        NODE_PROPIO="$DESTINO/node/bin/node"
        bien "$(t "Node $("$NODE_PROPIO" -v) quedó dentro de Manoo (no tocamos tu sistema)" "Node $("$NODE_PROPIO" -v) is now inside Manoo (your system was not touched)")"
        [ -f "$DESTINO/node/LICENSE" ] || curl -fsSL "https://raw.githubusercontent.com/nodejs/node/v$NODE_VERSION/LICENSE" -o "$DESTINO/node/LICENSE" 2>/dev/null || true
      else
        mal "$(t 'No pude descomprimir Node.' 'Could not unpack Node.')"
      fi
    else
      mal "$(t 'No pude bajar Node.' 'Could not download Node.')"
      info "$(t 'Puedes hacerlo a mano: https://nodejs.org y volver a correr esto.' 'Or do it by hand: https://nodejs.org and run this again.')"
    fi
  fi
fi

# ── 3. El programa ───────────────────────────────────────────────────────────
titulo "$(t 'Bajar Manoo' 'Download Manoo' "下载 Manoo")"
if [ "$FALTA" -gt 0 ] && ! existe node && [ -z "$NODE_PROPIO" ]; then
  printf '\n%s\n' "$(t 'Sin Node no puedo instalarlo. No toqué nada.' 'Without Node I cannot install it. I touched nothing.' '没有 Node 我没法安装。我什么都没动。')"
  exit 1
fi
if [ -d "$DESTINO/src" ]; then
  aviso "$(t "Ya había Manoo en $DESTINO: lo actualizo." "Manoo was already in $DESTINO: updating it.")"
fi
mkdir -p "$DESTINO" || { mal "$(t 'No pude crear la carpeta.' 'Could not create the folder.' '我无法创建文件夹。')"; exit 1; }
ZIP="$(mktemp -d)/manoo.zip"
info "$(t "Bajando de ${SITIO}…" "Downloading from ${SITIO}…")"
if curl -fsSL "$SITIO/descargas/$ARCHIVO" -o "$ZIP"; then
  # El zip trae una carpeta con la versión: se descomprime sin esa carpeta de más.
  if unzip -q -o "$ZIP" -d "$DESTINO.tmp"; then
    # El zip trae una carpeta con la versión; se copia su CONTENIDO (ojo con la
    # barra final: sin ella, «./» copiaba una carpeta con un punto en el nombre).
    INNER="$(ls -d "$DESTINO.tmp"/*/ 2>/dev/null | head -1)"
    if [ -n "$INNER" ]; then cp -R "${INNER}." "$DESTINO"/ || cp -R "${INNER}"* "$DESTINO"/; fi
    rm -rf "$DESTINO.tmp" "$ZIP"
    # Sin esto, los lanzadores no se pueden abrir con doble clic.
    chmod +x "$DESTINO/manoo" "$DESTINO/manoo.command" "$DESTINO/instalar.sh" 2>/dev/null
    chmod +x "$DESTINO"/bin/* 2>/dev/null
    bien "$(t "Manoo quedó en $DESTINO" "Manoo is now in $DESTINO" "Manoo 已经装到 $DESTINO")"
  else
    mal "$(t 'El archivo bajó pero no se pudo abrir.' 'The file downloaded but could not be opened.' '文件下载了，但打不开。')"
  fi
else
  mal "$(t "No pude bajar el programa de $SITIO" "Could not download the program from $SITIO" "我无法从 $SITIO 下载程序")"
fi

if [ ! -f "$DESTINO/src/manoo.mjs" ]; then
  printf '\n%s\n' "$(t 'Algo falló en la descarga. Vuelve a intentarlo en un minuto.' 'Something went wrong downloading. Try again in a minute.' '下载出了问题。请过一分钟再试。')"
  printf '%s\n\n' "$AVISOS"
  exit 1
fi

# ── 4. Permisos de macOS ─────────────────────────────────────────────────────
titulo "$(t 'Permisos que Manoo necesita' 'Permissions Manoo needs' "Manoo 需要的权限")"
NODE_BIN="${NODE_PROPIO:-node}"
DIAG="$(cd "$DESTINO" && "$NODE_BIN" src/manoo.mjs --info 2>/dev/null || true)"
if printf '%s' "$DIAG" | grep -q "viene de"; then
  LLAVE_HARNESS=1
fi
echo "$DIAG" | grep -q "✅ Accesibilidad" && bien "$(t 'Accesibilidad' 'Accessibility' '辅助功能')" \
  || { mal "$(t 'Accesibilidad (mover el mouse y escribir por ti)' 'Accessibility (to move the mouse and type for you)' "辅助功能（帮你移动鼠标、打字）")"; }
echo "$DIAG" | grep -q "✅ Grabación de pantalla" && bien "$(t 'Grabación de pantalla' 'Screen Recording' '屏幕录制')" \
  || { mal "$(t 'Grabación de pantalla (las capturas; sin esto salen negras)' 'Screen Recording (screenshots; without it they come out black)' "屏幕录制（截图；没有它截图是黑的）")"; }
# El de Monitoreo de entrada no se puede leer del diagnóstico: se prueba de verdad
# levantando el vigía (si no tiene permiso, lo dice él mismo). Así no sale un ✗ falso.
VIGIA="$(cd "$DESTINO" && ./bin/manoo-ui vigilar < /dev/null 2>&1 | head -1 || true)"
case "$VIGIA" in
  *permiso_monitoreo*|*"no pude crear el vigía"*)
    mal "$(t 'Monitoreo de entrada: SIN ESTO MANOO NO SE DETIENE al tocar el mouse' 'Input Monitoring: WITHOUT IT MANOO DOES NOT STOP when you touch the mouse' "输入监控：没有它，你碰鼠标时 Manoo 不会停")" ;;
  *'"listo":true'*)
    bien "$(t 'Monitoreo de entrada (el paro de emergencia funciona)' 'Input Monitoring (the emergency stop works)' '输入监控（紧急停止可用）')" ;;
  *)
    aviso "$(t 'No pude comprobar el paro de emergencia; si tocar el mouse no detiene a Manoo, da ese permiso.' 'I could not check the emergency stop; if touching the mouse does not stop Manoo, grant that permission.' '我没能检查紧急停止；如果你碰鼠标时 Manoo 不停，请给这个权限。')" ;;
esac
if [ "$FALTA" -gt 0 ]; then
  printf '\n  %s%s%s\n' "$B" "$(t 'Cómo se dan (dos minutos):' 'How to grant them (two minutes):' "怎么给权限（两分钟）：")" "$N"
  info "$(t '1. Abre Configuración del Sistema → Privacidad y seguridad.' '1. Open System Settings → Privacy & Security.' "1. 打开 系统设置 → 隐私与安全性。")"
  info "$(t '2. Entra a Accesibilidad, Grabación de pantalla y Monitoreo de entrada.' '2. Open Accessibility, Screen Recording and Input Monitoring.' "2. 进入 辅助功能、屏幕录制 和 输入监控。")"
  info "$(t "3. Activa la app desde donde corres esto (Terminal, iTerm…)." "3. Turn on the app you are running this from (Terminal, iTerm…)." "3. 打开你运行这个的 App（终端、iTerm…）。")"
  esperar
else
  info "$(t 'Ya están los tres: Manoo puede trabajar y detenerse.' 'All three are on: Manoo can work and can stop.' "三项都有了：Manoo 可以工作，也可以停下。")"
fi

# ── 5. Tu llave de DeepSeek ──────────────────────────────────────────────────
titulo "$(t 'Tu llave de DeepSeek' 'Your DeepSeek key' "你的 DeepSeek 密钥")"
LLAVE="$HOME/.config/manoo/deepseek.key"
if [ "${LLAVE_HARNESS:-0}" = "1" ]; then
  # Ya la encontró solo: la que usa DeepSeek Harness en esta máquina. No hay que pedir nada.
  bien "$(t 'Ya encontré tu llave: es la que usa DeepSeek Harness en esta máquina.' 'I already found your key: the one DeepSeek Harness uses on this machine.' "我已经找到你的密钥：就是这台机器上 DeepSeek Harness 用的那个。")"
elif [ -s "$LLAVE" ]; then
  bien "$(t 'Ya tienes una llave guardada.' 'You already have a saved key.' "你已经保存了密钥。")" 
  info "$(t 'Es la que te da platform.deepseek.com (empieza con sk-) y es la que deja a Manoo pensar.' 'It is the one platform.deepseek.com gives you (starts with sk-) and it is what lets Manoo think.' "在 platform.deepseek.com 领取（以 sk- 开头），它让 Manoo 会思考。")"
  if preguntar "$(t '¿La pego ahora? (no se verá en pantalla mientras la escribes)' 'Paste it now? (it will not show on screen while you type it)' '现在就粘贴吗？（输入时屏幕上不会显示）')"; then
    printf '  %s%s%s' "$B" "$(t 'Pega la llave y presiona Enter: ' 'Paste the key and press Enter: ' '粘贴密钥后按回车：')" "$N" > /dev/tty
    read -rs K < /dev/tty || K=""
    printf '\n' > /dev/tty
    if [ -n "${K:-}" ]; then
      mkdir -p "$(dirname "$LLAVE")" && printf '%s' "$K" > "$LLAVE" && chmod 600 "$LLAVE" \
        && bien "$(t 'Guardada (solo la puedes leer tú: permisos 600).' 'Saved (only you can read it: mode 600).' "已保存（只有你能读：权限 600）。")" \
        || mal "$(t 'No pude guardarla.' 'Could not save it.' "我没能保存它。")"
    else
      aviso "$(t 'No pegaste nada; la puedes poner después.' 'You pasted nothing; you can add it later.' '你没有粘贴任何内容；以后也可以再填。')"
    fi
  else
    info "$(t "Después:  printf '%s' 'TU_LLAVE' > ~/.config/manoo/deepseek.key && chmod 600 ~/.config/manoo/deepseek.key" "Later:  printf '%s' 'YOUR_KEY' > ~/.config/manoo/deepseek.key && chmod 600 ~/.config/manoo/deepseek.key" "以后可以这样：printf '%s' '你的密钥' > ~/.config/manoo/deepseek.key && chmod 600 ~/.config/manoo/deepseek.key")"
  fi
fi

# ── 6. Listo ─────────────────────────────────────────────────────────────────
titulo "$(t 'Listo' 'Done' "完成")"
printf '  %s%s%s\n' "$V" "$(t 'Manoo quedó instalado.' 'Manoo is installed.' "Manoo 已经安装好了。")" "$N"
printf '\n  %s%s%s\n' "$B" "$(t 'Cómo se usa:' 'How to use it:' "怎么用：")" "$N"
info "$(t "1. Doble clic en $DESTINO/manoo.command (o corre: $DESTINO/manoo)" "1. Double-click $DESTINO/manoo.command (or run: $DESTINO/manoo)" "1. 双击 $DESTINO/manoo.command（或者运行：$DESTINO/manoo）")"
info "$(t '2. Escríbele lo que quieres, como se lo dirías a una persona.' '2. Type what you want, the way you would tell a person.' '2. 像跟人说话一样，把你想做的事写给它。')"
info "$(t '3. La barra de Manoo aparece abajo a la izquierda: ahí prendes la voz y la pausa.' '3. The Manoo bar shows up at the bottom left: that is where you turn the voice and the pause on.' '3. Manoo 的状态栏出现在左下角：在那里开关声音和暂停。')"
printf '\n  %s%s%s\n' "$B" "$(t '¿Usas DeepSeek Harness?' 'Do you use DeepSeek Harness?' "你用 DeepSeek Harness 吗？")" "$N"
info "$(t 'Instala el conector desde el mercado de plugins (busca «Manoo»), o corre:' 'Install the connector from the plugin market (search for «Manoo»), or run:' "在插件市场安装连接器（搜「Manoo」），或者运行：")"
info "dsh plugin --profile web add manoo-manos"
printf '\n  %s%s%s\n' "$B" "$(t 'Tu plan' 'Your plan' "你的套餐")" "$N"
info "$(t 'Gratis: 25 acciones por sesión. Pro (ilimitado): se activa con la llave que te llega al comprar.' 'Free: 25 actions per session. Pro (unlimited): activated with the key you get when you buy.' "免费：每次会话 25 步操作。Pro（不限量）：用购买后收到的密钥激活。")"
printf '\n  %s\n' "$(t "Para ver el diagnóstico cuando quieras:  cd $DESTINO && ./node/bin/node src/manoo.mjs --info" "To see the diagnosis anytime:  cd $DESTINO && ./node/bin/node src/manoo.mjs --info" "想看诊断时：cd $DESTINO && ./node/bin/node src/manoo.mjs --info")"
[ -n "$AVISOS" ] && printf '\n  %s%s%s\n%s\n' "$A" "$(t 'Quedó algo pendiente:' 'Something is still pending:' "还有几项没完成：")" "$N" "$AVISOS"
printf '\n'
exit 0
