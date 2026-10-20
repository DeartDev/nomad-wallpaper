#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

BIN_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nomad-wallpaper"

BIN_PATH="$BIN_DIR/nomad-wallpaper"
CONFIG_PATH="$CONFIG_DIR/config"
SERVICE_SRC="$REPO_DIR/systemd/nomad-wallpaper.service"
TIMER_SRC="$REPO_DIR/systemd/nomad-wallpaper.timer"

fail() {
  echo "✗ $*" >&2
  exit 1
}

# --- Preflight -----------------------------------------------------------------

command -v plasma-apply-wallpaperimage &>/dev/null || fail "plasma-apply-wallpaperimage not found (install plasma-workspace)"
command -v systemctl &>/dev/null || fail "systemctl not found (systemd is required)"

bash -n "$REPO_DIR/nomad-wallpaper" || fail "syntax error in nomad-wallpaper"

if command -v shellcheck &>/dev/null; then
  shellcheck "$REPO_DIR/nomad-wallpaper" "$REPO_DIR"/*.sh || fail "shellcheck reported errors"
fi

WARNINGS=()
command -v magick &>/dev/null || WARNINGS+=("ImageMagick (magick) not found — fitting modes disabled, images applied as-is")
command -v xrandr &>/dev/null || command -v xdpyinfo &>/dev/null || WARNINGS+=("xrandr/xdpyinfo not found — screen resolution must be set in $CONFIG_PATH")
[[ ":$PATH:" == *":$BIN_DIR:"* ]] || WARNINGS+=("$BIN_DIR is not in your PATH — add it to run 'nomad-wallpaper' manually")

# --- Install -------------------------------------------------------------------

echo "Installing Nomad Wallpaper..."

mkdir -p "$BIN_DIR" "$SERVICE_DIR"

cp "$REPO_DIR/nomad-wallpaper" "$BIN_PATH"
chmod +x "$BIN_PATH"
echo "  Script → $BIN_PATH"

cp "$SERVICE_SRC" "$SERVICE_DIR/nomad-wallpaper.service"
cp "$TIMER_SRC" "$SERVICE_DIR/nomad-wallpaper.timer"
echo "  Service → $SERVICE_DIR/nomad-wallpaper.service"
echo "  Timer   → $SERVICE_DIR/nomad-wallpaper.timer"

if [[ ! -f "$CONFIG_PATH" ]]; then
  mkdir -p "$CONFIG_DIR"
  cp "$REPO_DIR/config.example" "$CONFIG_PATH"
  echo "  Config  → $CONFIG_PATH (new)"
else
  echo "  Config  → $CONFIG_PATH (kept)"
fi

systemctl --user daemon-reload
systemctl --user enable nomad-wallpaper.timer
systemctl --user restart nomad-wallpaper.timer

echo ""
echo "✓ Nomad Wallpaper installed."
echo "  Timer is active — wallpaper will update every 15 minutes."
echo "  Run 'nomad-wallpaper' manually to apply a wallpaper immediately."

for warning in "${WARNINGS[@]}"; do
  echo ""
  echo "⚠  WARNING: $warning"
done

if command -v loginctl &>/dev/null; then
  if loginctl show-user "$USER" 2>/dev/null | grep -q '^Linger=no'; then
    echo ""
    echo "⚠  WARNING: Linger is disabled for user '$USER'."
    echo "   The timer will stop firing when you close your session."
    echo "   Fix with:  sudo loginctl enable-linger $USER"
  fi
fi
