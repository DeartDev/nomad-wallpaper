# Plan de Mejora — Nomad Wallpaper

**Análisis original:** 2026-08-10 sobre v1.3.0 (commit `4685c65`)
**Última revisión:** 2026-10-20, tras v1.4.0 y v1.5.0

Prioridades: 🔴 **Alta** · 🟡 **Media** · 🟢 **Baja**

---

## 0. Estado

| Bloque | Estado |
|---|---|
| Discrepancias documentales (D-02 … D-07) | ✅ Cerradas |
| Robustez del script (M-01 … M-05, M-07, M-09) | ✅ Cerradas |
| Timer | ✅ Cerrado (`OnCalendar` único) |
| Configuración persistente (M-06) | ✅ Cerrada |
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

**Nota sobre D-04:** el plan original proponía mantener `Persistent=true`. Se descartó porque la ejecución de recuperación al arrancar llega antes de que exista sesión de Plasma (falla) o provoca dos cambios seguidos. La continuidad tras un apagado no depende del timer sino del estado en disco (`playlist.txt`, `seen.txt`, `last`).

**Nota sobre S-05:** `PrivateTmp=yes` no se añadió; en unidades de usuario depende de user namespaces y no aporta nada (el script no usa `/tmp`).

---

## 2. Pendiente

### Fase 6 — CI y calidad · 🟡 (cierra S-08)
1. GitHub Actions con `shellcheck` (bloqueante) y `shfmt -d` (informativo) en push/PR.
2. Tests con `bats-core` 🟢: `sync_playlist` (altas, bajas, duplicados), `start_cycle` (sin repetir la última imagen), `migrate_legacy_state`, y que un fallo de `plasma-apply-wallpaperimage` no consuma la imagen. Usar un `HOME` de fixtures y stubs de `plasma-apply-wallpaperimage` y `xrandr` en `PATH`.
3. Badge de CI en el README.

### Fase 7 — Mejoras funcionales opcionales · 🟢
1. M-08: detección de resolución con `kscreen-doctor` (Wayland sin XWayland) y caché de la resolución.
2. Multi-monitor: resolución por pantalla (hoy solo se usa la primaria).
3. Subcomandos CLI: `nomad-wallpaper next|status|reshuffle`.

### Menores · 🟢
- M-04: rotación de `nomad.log`. Solo crece con `-v` y el servicio no lo usa por defecto.
- Nombres de archivo con salto de línea rompen el formato por líneas de la playlist (caso patológico, se acepta).

---

## 3. Descartado

| ID | Motivo |
|---|---|
| D-01 / Fase 4 — Docker | El proyecto es un script de escritorio que necesita la sesión de Plasma (D-Bus, compositor); no tiene red, servidor ni puertos. Una política anti-puertos verificada con `grep` en un repo sin Docker solo añade ruido. Si la CI usa contenedor, basta con `--network=none`. |
| Fase 5 — `deploy.sh` | Duplicaba `install.sh`. Lo útil (preflight de dependencias, `bash -n`, ShellCheck, aviso de `PATH`) se integró en `install.sh` en v1.5.0; el backup con rollback no aporta porque el repo ya es la copia. |
