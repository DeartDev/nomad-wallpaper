# Nomad Wallpaper

Rotate your wallpapers randomly on KDE Plasma 6 — no repeats until you've seen them all.

## Features

- Random playlist from your wallpaper directory
- No repeated wallpapers until the full cycle completes
- New wallpapers join the current cycle; deleted ones are dropped automatically
- Resumes where it left off after a shutdown or reboot
- KDE Plasma 6 support (`plasma-apply-wallpaperimage`)
- Single-file Bash script, zero dependencies
- systemd timer (persistent, configurable interval)

## How it works

On each run, the script:

1. Syncs the playlist with the wallpaper directory: new images are inserted
   at random positions among the pending ones, missing images are dropped.
2. Applies the next pending entry as wallpaper.
3. Marks it as seen — only if it was applied successfully.

A systemd timer triggers the script every 15 minutes (`:00`, `:15`, `:30`, `:45`).
When every image has been shown, it reshuffles and starts a new cycle, never
opening with the image that closed the previous one.

State lives in `~/.local/share/nomad-wallpaper/`: `playlist.txt` (pending, in
order), `seen.txt` (already shown this cycle) and `last` (last applied image).

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
# Add:
# [Timer]
# OnCalendar=
# OnCalendar=*:0/30
systemctl --user daemon-reload
systemctl --user start nomad-wallpaper.timer
```

### Update wallpapers

Add new images to `~/Imágenes/Wallpapers` (or wherever `WALLPAPER_DIR` points).
New files are picked up on the next run and shuffled into the remaining part of
the current cycle. Deleted or renamed files are removed from the playlist.

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
sudo loginctl enable-linger "$USER"
```

The installer warns about this if it detects `Linger=no`.

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
