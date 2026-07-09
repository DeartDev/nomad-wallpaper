# Changelog

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
