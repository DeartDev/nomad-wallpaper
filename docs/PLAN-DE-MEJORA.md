# Plan de Mejora — Nomad Wallpaper

**Análisis original:** 2026-08-10 sobre v1.3.0 (commit `4685c65`)
**Última revisión:** 2026-10-20, tras v1.7.0

Prioridades: 🔴 **Alta** · 🟡 **Media** · 🟢 **Baja**

---

## 0. Estado

| Bloque | Estado |
|---|---|
| Discrepancias documentales (D-02 … D-07) | ✅ Cerradas |
| Robustez del script (M-01 … M-05, M-07, M-09) | ✅ Cerradas |
| Timer | ✅ Cerrado (`OnCalendar` único) |
| Configuración persistente (M-06) | ✅ Cerrada |
| Ajuste automático por imagen (`auto`, excepciones) | ✅ Añadido en v1.6.0 (fuera del plan original) |
| Instalación en un PC nuevo (carpeta de wallpapers) | ✅ Añadido en v1.6.1 |
| Seguridad (S-01 … S-07) | ✅ Cerradas o aceptadas |
| CI con ShellCheck (S-08) | ⏳ Pendiente |
| Mejoras opcionales (Fase 7) | ⏳ Pendiente |
| Docker (D-01, Fase 4) y `deploy.sh` (Fase 5) | ❌ Descartados |

---

## 1. Puntos cerrados

| ID | Punto | Resuelto en |
|---|---|---|
| D-02 | README afirmaba "zero dependencies" | v1.5.0 — requisitos reales listados |
| D-03 | Instrucción de cambio de intervalo rota | v1.4.0 — se documenta el override de `OnCalendar` |
| D-04 | Triggers del timer solapados | v1.4.0 — solo `OnCalendar=*:0/15` (ver nota) |
| D-05 | Usuario hardcodeado en `enable-linger` | v1.4.0 — `"$USER"` |
| D-06 | Notas internas de v1.0.0 en la raíz | v1.5.0 — movidas a `docs/archive/` |
| D-07 | Configuración perdida al reinstalar | v1.5.0 — vía M-06 |
| M-01 | Colección vacía | v1.4.0 — error explícito «no wallpapers found» |
| M-02 | Imagen actual borrada bloqueaba la rotación | v1.4.0 — la playlist se sincroniza con el directorio en cada ejecución |
| M-03 | `processed-*.jpg` huérfanos | v1.4.0 — solo se conserva el que está en uso |
| M-05 | Guardas en `advance_playlist` | v1.4.0 — función eliminada; ya no hay índice numérico |
| M-06 | Archivo de configuración persistente | v1.5.0 — `~/.config/nomad-wallpaper/config`, creado por el instalador desde `config.example` |
| M-07 | Directorio por defecto no portable | v1.5.0 — `xdg-user-dir PICTURES` con fallback a `~/Pictures` |
| M-09 | `sort \| shuf`, `mkdir -p` repetido, preflight en `install.sh` | v1.4.0 / v1.5.0 |
| S-03 | `read -rp` en ejecución no interactiva | v1.5.0 — guarda `[[ -t 0 ]]` |
| S-05 | Hardening systemd | v1.5.0 — `NoNewPrivileges=yes` |
| S-06 | Implicación de linger sin documentar | v1.5.0 — documentada en README |
| S-07 | Config `source`-ada | v1.5.0 — modelo de confianza documentado (README y `config.example`) |

## 1b. Añadido fuera del plan original

| Punto | Resuelto en |
|---|---|
| Modo `auto` (nuevo por defecto): `fill` si la proporción es parecida (recorte ≤ `AUTO_MAX_CROP`, 25 % por defecto) y no hace falta ampliar más de `MAX_UPSCALE` (150 %); si no, la imagen entera sobre el color de sus bordes (`pad`, cuando son lisos) o sobre una copia difuminada (`blur`) | v1.6.0 |
| Modos `blur` y `pad` seleccionables a mano, con ampliación limitada | v1.6.0 |
| Excepciones por imagen en `~/.config/nomad-wallpaper/overrides` (`<modo> <patrón>`), creado por el instalador desde `overrides.example` | v1.6.0 |
| Si falla el procesado, se aplica la imagen original y se registra un aviso | v1.6.0 |
| `install.sh` crea la carpeta de wallpapers (por defecto o `WALLPAPER_DIR`) e indica dónde añadir imágenes | v1.6.1 |

Verificado con las 129 imágenes reales a 1920x1080: 119 → `fill`, 10 → imagen entera (6 pequeñas, 1 cuadrada, 2 verticales y una 4:3 que recortaba un 26 %). Con `AUTO_MAX_CROP=30` en la configuración local, esa 4:3 pasa a `fill`. Coste medio ≈ 0,7 s por cambio (hasta ~2 s con imágenes muy grandes).

**Nota sobre D-04:** el plan original proponía mantener `Persistent=true`. Se descartó porque la ejecución de recuperación al arrancar llega antes de que exista sesión de Plasma (falla) o provoca dos cambios seguidos. La continuidad tras un apagado no depende del timer sino del estado en disco (`playlist.txt`, `seen.txt`, `last`).

**Nota sobre S-05:** `PrivateTmp=yes` no se añadió; en unidades de usuario depende de user namespaces y no aporta nada (el script no usa `/tmp`).

---

## 2. Pendiente

### Fase 6 — CI y calidad · 🟡 (cierra S-08)
1. GitHub Actions con `shellcheck` (bloqueante) y `shfmt -d` (informativo) en push/PR.
2. Tests con `bats-core` 🟢: `sync_playlist` (altas, bajas, duplicados), `start_cycle` (sin repetir la última imagen), `migrate_legacy_state`, y que un fallo de `plasma-apply-wallpaperimage` no consuma la imagen. También `resolve_auto_mode` (fill / pad / blur según tamaño, proporción y bordes), `override_mode` (patrones con espacios, modo inválido ignorado) y la creación de la carpeta en `install.sh`. Usar un `HOME` de fixtures y stubs de `plasma-apply-wallpaperimage`, `xrandr`, `xdg-user-dir` y `systemctl` en `PATH`.
3. Badge de CI en el README.

### Fase 7 — Mejoras funcionales opcionales · 🟢
1. M-08: detección de resolución con `kscreen-doctor` (Wayland sin XWayland) y caché de la resolución.
2. Multi-monitor: resolución por pantalla (hoy solo se usa la primaria).
3. Subcomandos CLI: `next` y `reshuffle`. (`status` y `status --all`, con el modo que recibirá cada imagen, ✅ hechos en v1.7.0.)
4. Caché de imágenes procesadas (clave: ruta + mtime + resolución + modo) para evitar reprocesar en cada vuelta. Hoy no es necesario por el coste (< 2 s cada 15 min).

### Menores · 🟢
- `config` creados con una versión anterior no incluyen las opciones nuevas (`AUTO_MAX_CROP`, `MAX_UPSCALE`) como comentario; el instalador nunca sobrescribe la config. Opcional: avisar en `install.sh` de opciones nuevas disponibles en `config.example`.
- M-04: rotación de `nomad.log`. Solo crece con `-v` y el servicio no lo usa por defecto.
- Nombres de archivo con salto de línea rompen el formato por líneas de la playlist (caso patológico, se acepta).

---

## 3. Descartado

| ID | Motivo |
|---|---|
| D-01 / Fase 4 — Docker | El proyecto es un script de escritorio que necesita la sesión de Plasma (D-Bus, compositor); no tiene red, servidor ni puertos. Una política anti-puertos verificada con `grep` en un repo sin Docker solo añade ruido. Si la CI usa contenedor, basta con `--network=none`. |
| Fase 5 — `deploy.sh` | Duplicaba `install.sh`. Lo útil (preflight de dependencias, `bash -n`, ShellCheck, aviso de `PATH`) se integró en `install.sh` en v1.5.0; el backup con rollback no aporta porque el repo ya es la copia. |
