# Nomad Wallpaper

Rotate your wallpapers randomly on KDE Plasma 6 — no repeats until you've seen them all.

## Features

- Random playlist from your wallpaper directory
- No repeated wallpapers until the full cycle completes
- KDE Plasma 6 support (`plasma-apply-wallpaperimage`)
- Single-file Bash script, zero dependencies
- systemd timer (persistent, configurable interval)

## How it works

On each run, the script:

1. Reads a shuffled playlist (or creates one if none exists).
2. Applies the current entry as wallpaper.
3. Advances to the next entry for the next run.

A systemd timer triggers the script every 15 minutes. When the playlist is exhausted, it reshuffles and starts over.

## Installation

```bash
git clone https://github.com/DeartDev/nomad-wallpaper.git
cd nomad-wallpaper
./install.sh
```

The installer copies the script to `~/.local/bin/` and sets up the systemd timer.

### Requirements

- KDE Plasma 6
- systemd (user services enabled)
- `~/.local/bin/` in your `PATH` (add it if missing)

## Configuration

By default the script looks for images in `~/Imágenes/Wallpapers`. To change this, edit the variables at the top of the script:

```bash
WALLPAPER_DIR="$HOME/Imágenes/Wallpapers"
WALLPAPER_MODE="fill"   # fill | fit | center | tile | stretch | none
```

| Mode | Effect |
|---|---|
| `fill` | Scales and crops to fill the screen (no black bars) |
| `fit` | Scales to fit entirely (black bars if aspect ratio differs) |
| `center` | Original size, centered with black bars |
| `tile` | Repeats the image as a mosaic |
| `stretch` | Forced stretch, ignores aspect ratio |
| `none` | No processing, as-is |

Requires ImageMagick (`magick`) for modes other than `none` — automatic fallback if not installed.

Supported formats: `jpg`, `jpeg`, `png`, `webp`.

## Usage

### Run manually

```bash
nomad-wallpaper              # quiet mode (default)
nomad-wallpaper -v           # verbose mode (writes to ~/.local/share/nomad-wallpaper/nomad.log)
nomad-wallpaper -h           # help
```

### Check timer status

```bash
systemctl --user status nomad-wallpaper.timer
```

### Change interval

```bash
systemctl --user stop nomad-wallpaper.timer
systemctl --user edit nomad-wallpaper.timer
# Change OnUnitActiveSec to your preferred interval
systemctl --user daemon-reload
systemctl --user start nomad-wallpaper.timer
```

### Update wallpapers

Add new images to `~/Imágenes/Wallpapers` (or wherever `WALLPAPER_DIR` points).
The new files are picked up automatically when the playlist cycles back to the start.

### Verbose logs

Run `nomad-wallpaper -v` manually to append timestamped entries to
`~/.local/share/nomad-wallpaper/nomad.log`. To enable verbose logging from the
systemd timer, override the service:

```bash
systemctl --user edit nomad-wallpaper.service
# Add:
# [Service]
# ExecStart=
# ExecStart=%h/.local/bin/nomad-wallpaper -v
systemctl --user daemon-reload
```

## Troubleshooting

### Timer stops firing after I log out

By default, systemd kills all user services when your session ends.
Fix it once with:

```bash
sudo loginctl enable-linger deartdev
```

The installer warns about this if it detects `Linger=no`.

### Timer is "active (elapsed)" but no wallpaper changes

This happens when the timer was started mid-session (not at boot):
`OnBootSec` already elapsed and `OnUnitActiveSec` has no previous
activation to count from. Prime it once:

```bash
systemctl --user start nomad-wallpaper.service
```

### Wallpaper doesn't change even though the service runs

Check that the required tools are installed:

```bash
command -v plasma-apply-wallpaperimage   # comes with plasma-workspace
command -v xrandr                        # usually preinstalled
command -v magick                        # optional, for fitting modes
```

Then run `nomad-wallpaper -v` and inspect `~/.local/share/nomad-wallpaper/nomad.log`.

### Inspect recent executions

```bash
journalctl --user -u nomad-wallpaper.service -n 30
journalctl --user -u nomad-wallpaper.timer -n 10
```

## Uninstall

```bash
cd nomad-wallpaper
./uninstall.sh
```

## License

MIT
