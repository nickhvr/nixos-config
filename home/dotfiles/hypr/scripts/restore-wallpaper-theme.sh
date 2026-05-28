#!/usr/bin/env bash

set -u

WAL_CACHE="$HOME/.cache/wal"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
DEFAULT_WALLPAPER="$HOME/wallpapers/wallpaper.png"
HYPRPAPER_LOG="/tmp/hyprpaper-restore.log"

mkdir -p "$WAL_CACHE" "$HOME/.config/hypr"

wallpaper="$(cat "$WAL_CACHE/current-wallpaper" 2>/dev/null || true)"

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    wallpaper="$DEFAULT_WALLPAPER"
    rm -f "$WAL_CACHE/current-wallpaper"
    printf '%s\n' "$wallpaper" > "$WAL_CACHE/current-wallpaper"
fi

monitors="$(hyprctl monitors | awk '/^Monitor / {print $2}')"

{
    echo "ipc = on"
    echo "splash = false"
    echo "preload = $wallpaper"

    if [ -n "$monitors" ]; then
        for monitor in $monitors; do
            echo "wallpaper = $monitor,$wallpaper"
        done
    else
        echo "wallpaper = ,$wallpaper"
    fi
} > "$HYPRPAPER_CONF"

: > "$HYPRPAPER_LOG"

if pgrep -x hyprpaper >/dev/null 2>&1; then
    timeout 2s hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true

    if [ -n "$monitors" ]; then
        for monitor in $monitors; do
            timeout 2s hyprctl hyprpaper wallpaper "$monitor,$wallpaper" >/dev/null 2>&1 || true
        done
    else
        timeout 2s hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true
    fi
else
    if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        rm -f "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.hyprpaper.sock"
    fi

    hyprpaper >>"$HYPRPAPER_LOG" 2>&1 &
    sleep 1
fi

if command -v wal >/dev/null 2>&1; then
    wal -i "$wallpaper" -n -q || true
fi

if [ -x "$HOME/.config/hypr/scripts/apply-wal-theme.sh" ]; then
    "$HOME/.config/hypr/scripts/apply-wal-theme.sh" || true
fi
