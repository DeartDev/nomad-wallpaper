# Nomad Wallpaper

Rotate your wallpapers randomly on KDE Plasma 6 — no repeats until you've seen them all.

## Features

- Random playlist from your wallpaper directory
- No repeated wallpapers until the full cycle completes
- New wallpapers join the current cycle; deleted ones are dropped automatically
- Resumes where it left off after a shutdown or reboot
- KDE Plasma 6 support (`plasma-apply-wallpaperimage`)
- Single-file Bash script — only standard Plasma/systemd tools, ImageMagick optional
- systemd timer (configurable interval)
- `auto` fitting: picks the best layout for each image (crop, blurred background or solid padding)
- Per-image overrides
- Persistent user configuration that survives reinstalls

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

The installer checks dependencies, copies the script to `~/.local/bin/`, sets up
the systemd timer, creates `~/.config/nomad-wallpaper/config` and `overrides`
if they don't exist (existing ones are never overwritten) and creates the
wallpaper directory (`<XDG Pictures dir>/Wallpapers` or your `WALLPAPER_DIR`).

Then just copy your images into that directory — the installer prints its path.

### Requirements

- KDE Plasma 6 (`plasma-apply-wallpaperimage`, from plasma-workspace)
- systemd (user services enabled)
- `xrandr` or `xdpyinfo` for screen resolution detection (or set `SCREEN_RES`)
- ImageMagick (`magick`) — optional, needed for fitting modes other than `none`
- `~/.local/bin/` in your `PATH` to run it manually (the installer warns if missing)

## Configuration

Edit `~/.config/nomad-wallpaper/config` (see [`config.example`](config.example)).
Changes apply on the next run and survive reinstalls:

```bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"   # default: <XDG Pictures dir>/Wallpapers
WALLPAPER_MODE="auto"                       # auto | fill | fit | blur | pad | center | tile | stretch | none
SCREEN_RES="1920x1080"                      # default: auto-detected
```

By default images are read from the `Wallpapers` folder inside your XDG
Pictures directory (`xdg-user-dir PICTURES`, e.g. `~/Pictures/Wallpapers` or
`~/Imágenes/Wallpapers`).

The config file is sourced as Bash, so keep it owned by you and not writable
by others (same trust model as `~/.bashrc`).

| Mode | Effect |
|---|---|
| `auto` | **Default.** Chooses per image: `fill`, `blur` or `pad` (see below) |
| `fill` | Scales and crops to fill the screen (no black bars) |
| `blur` | Whole image centered over a blurred, darkened copy of itself |
| `pad` | Whole image centered over the color of its own edges |
| `fit` | Scales to fit entirely (black bars if aspect ratio differs) |
| `center` | Original size, centered with black bars |
| `tile` | Repeats the image as a mosaic |
| `stretch` | Forced stretch, ignores aspect ratio |
| `none` | No processing, as-is |

Requires ImageMagick (`magick`) for modes other than `none` — automatic fallback if not installed.

### How `auto` decides

1. If the image has a similar aspect ratio to the screen — `fill` would crop
   at most `AUTO_MAX_CROP` % (default 25) — and doesn't need more than
   `MAX_UPSCALE` % (default 150) to cover it → **`fill`**.
2. Otherwise the whole image is shown, upscaled at most `MAX_UPSCALE` %:
   - edges of a single solid color (e.g. a black background) → **`pad`** with that color;
   - any other image → **`blur`**.

`blur` and `pad` never upscale beyond `MAX_UPSCALE` %, so small images stay sharp.
Run with `-v` to log the decision taken for each image.

### Per-image overrides

When `auto` doesn't pick what you want, add a rule to
`~/.config/nomad-wallpaper/overrides` (see [`overrides.example`](overrides.example)):

```
# <mode> <file name pattern>
fill   samurai-*.png
blur   my photo with spaces.jpg
```

The pattern is a Bash glob matched against the file name; the first match wins.

Supported formats: `jpg`, `jpeg`, `png`, `webp`.

## Usage

### Run manually

```bash
nomad-wallpaper              # quiet mode (default)
nomad-wallpaper -v           # verbose mode (writes to ~/.local/share/nomad-wallpaper/nomad.log)
nomad-wallpaper status       # show rotation state (see below)
nomad-wallpaper -h           # help
```

### Check rotation status

```bash
nomad-wallpaper status         # directory, mode, cycle progress, current/next image, next change
nomad-wallpaper status --all   # also every image in order, with the mode it will use
```

`status` is read-only: it never changes the playlist or the wallpaper. Images
added or removed since the last run are reported as pending sync.

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

Add new images to your wallpaper directory (`WALLPAPER_DIR`).
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

The installer warns about this if it detects `Linger=no`. Note that linger keeps
your user's systemd services running even when you are not logged in.

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
