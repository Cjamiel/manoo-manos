# Manoo · manos para DeepSeek Harness

**Manoo le da manos a DeepSeek**: ve tu pantalla, mueve el mouse y escribe por ti.
Le pides las cosas como se las pedirías a una persona —«abre el navegador y busca
el clima», «enséñame dónde está el botón de guardar»— y lo hace delante de ti, con
una **barra** en la pantalla, un **aro** que te señala dónde picar y **voz** que te
va contando.

Está hecho para **quien no sabe usar la computadora**, en **español**, y para que
termines la sesión **habiendo aprendido algo**, no solo con el resultado.

![Manoo trabajando con DeepSeek: el chat a la izquierda, los resultados a la derecha y el aro señalando el primer resultado](captura.png)

---

## Qué es este paquete (y qué no)

Este repositorio es **solo el conector**: le dice a DeepSeek Harness cómo hablar con
Manoo usando el puente oficial `@deepseek-ai/dsh-mcp-client`. **No contiene el
programa Manoo.**

El programa se descarga aparte en **https://manoo.corporacionjamiel.workers.dev/**
(hay **prueba gratis de 25 acciones** por sesión; Pro es ilimitado). Se instala en
tu Mac y este conector lo engancha al harness.

## Instalación (dos pasos)

**1. Instala el conector** desde el Plugin Market del harness, o a mano:

```bash
dsh plugin --profile web add manoo-manos
```

**2. Baja Manoo y apúntale la ruta**

Descarga Manoo de https://manoo.corporacionjamiel.workers.dev/, descomprímelo en tu
carpeta personal como `manoo`, y corre:

```bash
node instalar.mjs
```

Eso escribe la ruta real de tu copia en el conector. Después **reinicia DeepSeek
Harness** y ya puedes pedirle cosas. Si tienes Manoo en otro lado:

```bash
MANOO_HOME=/ruta/a/manoo node instalar.mjs
```

## Cómo se usa

Escribe lo que quieres, como se lo dirías a una persona:

- **«ayúdame a llenar este formulario»** → Manoo hace los pasos de rutina y te deja
  solo lo que es tuyo: la contraseña, el botón que paga o firma.
- **«enséñame dónde está guardar»** → no toca nada: te señala con el **aro** y espera
  a que lo hagas tú.
- **«hazlo tú»** → lo hace sin preguntarte en los pasos de rutina.

Con el switch 🔊 de la barra te lo va **diciendo en voz alta**. Con la ✕ la barra se
apaga; con ⏸ **Manoo no toca nada** hasta que lo quites.

## Permisos que pide (macOS)

| Permiso | Para qué |
|---|---|
| **Accesibilidad** | mover el mouse, escribir y leer los botones de las apps |
| **Grabación de pantalla** | ver la pantalla cuando hace falta una captura |
| **Monitoreo de entrada** | el **paro de emergencia**: si tocas el mouse o el teclado, Manoo se detiene |

Sin el tercero, el paro no funciona: Manoo lo revisa al instalar y te lo dice.

## Lo que Manoo no hace (está en el código, no en un texto)

- **No escribe contraseñas, PIN, tarjetas ni códigos.** Nunca.
- **No pica el botón final** que paga, transfiere, firma, publica o envía: te dice
  dónde está y lo das tú.
- **No entra a apps de dinero, inversión, cripto, gestores de contraseñas ni
  autoridad fiscal** — no las abre ni las mira.
- **Si tocas el mouse o el teclado, se detiene** y te pregunta si sigue.
- Pide permiso **la primera vez que toca cada app**, con el aro sobre «Permitir».

## Privacidad, en claro

Manoo corre en tu computadora y **no manda nada a servidores nuestros**. Lo que Manoo
ve (texto de la pantalla y capturas) va a la **API de DeepSeek**, que lo procesa y lo
guarda en **China**. La licencia y el cobro los maneja la tienda; el aviso completo
está en https://manoo.corporacionjamiel.workers.dev/privacidad.html

## Alcance

Hoy **solo macOS**. Windows y Linux están en el proyecto de la versión para Claude.

## Licencia

El conector es gratis y se puede compartir tal cual; el **programa Manoo es aparte**
y tiene su propia licencia y precio. Ver [LICENSE](LICENSE).

Hecho por **Jamiel García Velázquez** · © 2026
