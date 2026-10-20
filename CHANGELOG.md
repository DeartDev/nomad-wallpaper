# Changelog

## v1.7.0 — 2026-10-20

### Added
- **`status` subcommand** (read-only): wallpaper directory and image count,
  mode and thresholds, override rules, screen resolution, cycle progress,
  current and next image, next timer run, and images pending sync.
- **`status --all`**: every image in order of appearance (pending, new,
  seen) with the mode it will actually get — `auto` decisions resolved and
  overrides marked — plus a count per mode.

## v1.6.1 — 2026-10-20

### Changed
- `install.sh` creates the wallpaper directory (default or `WALLPAPER_DIR`
  from the user config) if it doesn't exist, and prints where to add images
  or how many it found.

## v1.6.0 — 2026-10-20

### Added
- **`auto` fitting mode (new default)**: each image gets the layout that
  suits it. Similar aspect ratio and enough resolution → `fill`; otherwise
  the whole image is shown, padded with its edge color when the edges are a
  single solid color (`pad`) or over a blurred copy of itself (`blur`).
  Thresholds are configurable with `AUTO_MAX_CROP` (default 25 %) and
  `MAX_UPSCALE` (default 150 %).
- **`blur` and `pad` modes**, also selectable manually. Both cap upscaling
  at `MAX_UPSCALE` so small images aren't blown up.
- **Per-image overrides** in `~/.config/nomad-wallpaper/overrides`
  (`<mode> <glob>` per line); the installer creates it from
  `overrides.example` if missing.

### Changed
- An unknown `WALLPAPER_MODE` now falls back to `auto`.
- If processing fails, the original image is applied and a warning is logged.

## v1.5.0 — 2026-10-20

### Added
- **Persistent configuration** in `~/.config/nomad-wallpaper/config`
  (`WALLPAPER_DIR`, `WALLPAPER_MODE`, `SCREEN_RES`). It is sourced after the
  defaults, so it survives reinstalls; the installer creates it from
  `config.example` only if it doesn't exist.
- **Installer preflight**: fails if `plasma-apply-wallpaperimage` or
  `systemctl` are missing or the script has a syntax error (runs
  `shellcheck` when available); warns about missing ImageMagick,
  `xrandr`/`xdpyinfo` and `~/.local/bin` not in `PATH`.

### Changed
- Default wallpaper directory is `<XDG Pictures dir>/Wallpapers`
  (`xdg-user-dir PICTURES`, falling back to `~/Pictures`) instead of the
  hardcoded `~/Imágenes/Wallpapers`.
- Service runs with `NoNewPrivileges=yes`.
- Internal v1.0.0 work notes moved to `docs/archive/`.

### Fixed
- README claimed "zero dependencies"; it now lists the real requirements.
- An unknown `WALLPAPER_MODE` falls back to `fill` with a warning instead of
  failing every run.
- `uninstall.sh` no longer blocks on the state-data prompt when run
  non-interactively, and tells where the kept configuration lives.

## v1.4.0 — 2026-10-20

### Changed
- **Playlist is synced with the wallpaper directory on every run**: new
  images are inserted at random positions among the pending ones instead of
  waiting for the whole cycle to finish; deleted or renamed images are
  dropped. State is now `playlist.txt` (pending), `seen.txt` (shown this
  cycle) and `last`; the old `current` index is migrated automatically.
- **Timer uses a single trigger** (`OnCalendar=*:0/15`). The overlapping
  `OnBootSec`, `OnUnitActiveSec` and `Persistent` triggers could change the
  wallpaper twice within a few minutes after boot.

### Fixed
- **Rotation froze forever when the next image was deleted or renamed**:
  applying failed under `set -e` before the index advanced, so every run
  retried the same missing file.
- A wallpaper is only marked as seen after it was applied successfully
  (e.g. runs before Plasma is up no longer consume an image).
- A new cycle no longer starts with the image that ended the previous one.
- Concurrent runs (timer + manual) are serialized with `flock`.
- Stale `processed-*.jpg` files are removed; only the one in use is kept.

## v1.3.0 — 2026-07-24

### Fixed
- **Wallpaper only changed on the first run after boot**: the script wrote
  every processed image to the same fixed path (`~/.local/share/nomad-wallpaper/processed`).
  When `plasma-apply-wallpaperimage` was invoked with that same path on an
  `org.kde.image` containment, KDE did not re-render the wallpaper because
  the `Image=` entry in `plasma-org.kde.plasma.desktop-appletsrc` was
  unchanged. The script appeared to run fine (success exit, file mtime
  updated, playlist advanced) but the visible wallpaper was frozen.
  The processed file is now named after a hash of the source image path
  (`processed-<hash>.jpg`), giving each wallpaper a unique target so KDE
  always reloads it.

## v1.2.0 — 2026-07-23

### Fixed
- **Timer never fired after a mid-session login**: when the user logged in
  outside of a system boot, `OnBootSec` had already elapsed and
  `OnUnitActiveSec` had no previous activation to count from, leaving the
  timer loaded but with no scheduled next run. Added `OnCalendar=*:0/15` as a
  redundant absolute trigger and `Wants=graphical-session.target` on the
  service so the unit waits for Plasma to be ready.
- **User services stopped when the session closed**: documented and detected
  on install — the installer now warns when `Linger=no` and tells the user
  to run `sudo loginctl enable-linger`.
- **`get_current_wallpaper` could crash under `set -u` if `$CURRENT` was
  empty**: now guards against a missing or empty state file before reading
  it.

### Added
- `-v` / `--verbose` flag. When set, the script appends timestamped entries
  to `~/.local/share/nomad-wallpaper/nomad.log` covering resolution
  detection, playlist creation, mode fallback, and applied wallpapers.
- `-h` / `--help` flag.
- **Troubleshooting** section in the README covering the three most common
  failure modes (linger, mid-session login, missing dependencies).

## v1.1.0 — 2026-07-09

- Image fitting modes: fill, fit, center, tile, stretch (requires ImageMagick)
- Auto screen resolution detection (xrandr / xdpyinfo)
- Validation: error if wallpaper directory doesn't exist
- Graceful fallback if ImageMagick is not installed

## v1.0.0 — 2026-07-09

Initial release.

- Random playlist from wallpaper directory
- No repeated wallpapers until all have been shown
- Plasma 6 support (`plasma-apply-wallpaperimage`)
- systemd timer (15-minute interval, persistent)
- Single-file Bash script, no dependencies
