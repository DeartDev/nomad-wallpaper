#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

BIN_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"

BIN_PATH="$BIN_DIR/nomad-wallpaper"
SERVICE_SRC="$REPO_DIR/systemd/nomad-wallpaper.service"
TIMER_SRC="$REPO_DIR/systemd/nomad-wallpaper.timer"

echo "Installing Nomad Wallpaper..."

mkdir -p "$BIN_DIR" "$SERVICE_DIR"

cp "$REPO_DIR/nomad-wallpaper" "$BIN_PATH"
chmod +x "$BIN_PATH"
echo "  Script → $BIN_PATH"

cp "$SERVICE_SRC" "$SERVICE_DIR/nomad-wallpaper.service"
cp "$TIMER_SRC" "$SERVICE_DIR/nomad-wallpaper.timer"
echo "  Service → $SERVICE_DIR/nomad-wallpaper.service"
echo "  Timer   → $SERVICE_DIR/nomad-wallpaper.timer"

systemctl --user daemon-reload
systemctl --user enable --now nomad-wallpaper.timer

echo ""
echo "✓ Nomad Wallpaper installed."
echo "  Timer is active — wallpaper will update every 15 minutes."
echo "  Run 'nomad-wallpaper' manually to apply a wallpaper immediately."
