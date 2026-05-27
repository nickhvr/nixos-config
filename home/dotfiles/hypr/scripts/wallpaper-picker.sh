#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/wallpapers"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"
WAYBAR_LOG="$HOME/.cache/waybar.log"

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

monitors=$(hyprctl monitors | awk '/^Monitor / {print $2}')

# Persistent hyprpaper config
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

# Generate pywal colors
wal -i "$wallpaper" -n -q

# Generate valid Waybar GTK CSS colors
source "$HOME/.cache/wal/colors.sh"

cat > "$HOME/.cache/wal/waybar.css" <<EOF2
@define-color wal_bg ${background};
@define-color wal_fg ${foreground};
@define-color wal_accent ${color2};
@define-color wal_accent2 ${color6};
@define-color wal_dark ${color0};
@define-color wal_warning ${color3};
@define-color wal_critical ${color1};
EOF2

# Restart hyprpaper
pkill hyprpaper >/dev/null 2>&1 || true
sleep 0.3
hyprpaper >/tmp/hyprpaper-wallpaper-picker.log 2>&1 &

# Wait until hyprpaper IPC is ready
for i in {1..20}; do
    if hyprctl hyprpaper listloaded >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

# Apply wallpaper live
hyprctl hyprpaper unload all >/dev/null 2>&1 || true
hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true

if [ -n "$monitors" ]; then
    for monitor in $monitors; do
        hyprctl hyprpaper wallpaper "$monitor,$wallpaper" >/dev/null 2>&1 || true
    done
else
    hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true
fi

# Restart Waybar
pkill waybar >/dev/null 2>&1 || true
sleep 0.2
waybar > "$WAYBAR_LOG" 2>&1 &

notify-send "Wallpaper gesetzt" "$chosen"
