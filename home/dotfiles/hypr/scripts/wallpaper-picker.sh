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
    notify-send "Wallpaper" "Datei nicht gefunden: $wallpaper"
    exit 1
fi

mkdir -p "$HOME/.config/hypr"

cat > "$HYPRPAPER_CONF" <<EOF2
preload = $wallpaper
wallpaper = ,$wallpaper
EOF2

pgrep -x hyprpaper >/dev/null || hyprpaper &

sleep 0.2

hyprctl hyprpaper unload all >/dev/null 2>&1 || true
hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true
hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true

notify-send "Wallpaper gesetzt" "$chosen"
