# Changelog

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
