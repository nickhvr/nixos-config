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

monitors=$(hyprctl monitors | awk '/^Monitor / {print $2}')

{
    echo "preload = $wallpaper"

    if [ -n "$monitors" ]; then
        for monitor in $monitors; do
            echo "wallpaper = $monitor,$wallpaper"
        done
    else
        echo "wallpaper = ,$wallpaper"
    fi
} > "$HYPRPAPER_CONF"

# Generate pywal colors
wal -i "$wallpaper" -n -q

# Generate Waybar CSS variables from pywal
source "$HOME/.cache/wal/colors.sh"

cat > "$HOME/.cache/wal/waybar.css" <<EOF2
:root {
    --wal-bg: ${background};
    --wal-fg: ${foreground};
    --wal-accent: ${color2};
    --wal-accent2: ${color6};
    --wal-dark: ${color0};
    --wal-warning: ${color3};
    --wal-critical: ${color1};
}
EOF2

# Restart hyprpaper cleanly
pkill hyprpaper >/dev/null 2>&1 || true
sleep 0.2
hyprpaper >/dev/null 2>&1 &
sleep 0.5

# Apply wallpaper live to all monitors
hyprctl hyprpaper unload all >/dev/null 2>&1 || true
hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true

if [ -n "$monitors" ]; then
    for monitor in $monitors; do
        hyprctl hyprpaper wallpaper "$monitor,$wallpaper" >/dev/null 2>&1 || true
    done
else
    hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true
fi

# Reload visual components
pkill waybar >/dev/null 2>&1 || true
waybar >/dev/null 2>&1 &

notify-send "Wallpaper gesetzt" "$chosen"
