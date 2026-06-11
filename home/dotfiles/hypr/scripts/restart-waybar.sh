#!/usr/bin/env bash

set -euo pipefail

WAYBAR_CONFIG="${WAYBAR_CONFIG:-/etc/nixos/home/dotfiles/waybar/config}"
WAYBAR_STYLE="${WAYBAR_STYLE:-/etc/nixos/home/dotfiles/waybar/style.css}"
WAYBAR_LOG="${WAYBAR_LOG:-$HOME/.cache/waybar.log}"

mkdir -p "$(dirname "$WAYBAR_LOG")"

pkill -x waybar >/dev/null 2>&1 || true
waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" > "$WAYBAR_LOG" 2>&1 &
disown || true
