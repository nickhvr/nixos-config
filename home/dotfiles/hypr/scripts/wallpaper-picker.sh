#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/wallpapers"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "Ordner nicht gefunden: $WALLPAPER_DIR"
    exit 1
fi

chosen=$(
    while IFS= read -r -d '' file; do
        rel="${file#$WALLPAPER_DIR/}"
        printf '%s\0icon\x1f%s\n' "$rel" "$file"
    done < <(find "$WALLPAPER_DIR" -type f \( \
        -iname "*.png" -o \
        -iname "*.jpg" -o \
        -iname "*.jpeg" -o \
        -iname "*.webp" \
    \) -print0 | sort -z) | rofi -dmenu -i -show-icons -theme "$ROFI_THEME" -p "Wallpaper"
)

[ -z "$chosen" ] && exit 0

wallpaper="$WALLPAPER_DIR/$chosen"

if [ ! -f "$wallpaper" ]; then
    notify-send "Wallpaper" "Datei nicht gefunden" "$wallpaper"
    exit 1
fi

mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.cache/wal"

ln -sf "$wallpaper" "$HOME/.cache/wal/current-wallpaper"

monitors=$(hyprctl monitors | awk '/^Monitor / {print $2}')

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

pkill hyprpaper >/dev/null 2>&1 || true
sleep 0.3
hyprpaper >/tmp/hyprpaper-wallpaper-picker.log 2>&1 &
sleep 0.7

hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true

if [ -n "$monitors" ]; then
    for monitor in $monitors; do
        hyprctl hyprpaper wallpaper "$monitor,$wallpaper" >/dev/null 2>&1 || true
    done
else
    hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true
fi

if command -v wal >/dev/null 2>&1; then
    wal -i "$wallpaper" -n -q || true

    if [ -x "$HOME/.config/hypr/scripts/apply-wal-theme.sh" ]; then
        "$HOME/.config/hypr/scripts/apply-wal-theme.sh" || true
    fi
fi

notify-send "Wallpaper gesetzt" "$chosen"
