#!/usr/bin/env bash
set -euo pipefail

BIN_PATH="$HOME/.local/bin/nomad-wallpaper"
SERVICE_DIR="$HOME/.config/systemd/user"

SERVICE="$SERVICE_DIR/nomad-wallpaper.service"
TIMER="$SERVICE_DIR/nomad-wallpaper.timer"
STATE_DIR="$HOME/.local/share/nomad-wallpaper"

echo "Uninstalling Nomad Wallpaper..."

systemctl --user stop nomad-wallpaper.timer 2>/dev/null || true
systemctl --user disable nomad-wallpaper.timer 2>/dev/null || true

rm -f "$SERVICE" "$TIMER"
echo "  Removed systemd files"

rm -f "$BIN_PATH"
echo "  Removed script"

systemctl --user daemon-reload

if [[ -d "$STATE_DIR" ]]; then
  echo ""
  echo "  Playlist and state data found at:"
  echo "    $STATE_DIR"
  read -rp "  Remove wallpaper state data? [y/N] " REPLY
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm -rf "$STATE_DIR"
    echo "  State data removed"
  fi
fi

echo ""
echo "✓ Nomad Wallpaper uninstalled."
