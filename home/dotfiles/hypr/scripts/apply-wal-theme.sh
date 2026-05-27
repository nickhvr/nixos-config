#!/usr/bin/env bash

set -e

WAL_CACHE="$HOME/.cache/wal"
WAYBAR_LOG="$HOME/.cache/waybar.log"

mkdir -p "$WAL_CACHE"
mkdir -p "$HOME/.config/mako"

if [ ! -f "$WAL_CACHE/colors.sh" ]; then
    exit 0
fi

source "$WAL_CACHE/colors.sh"

# -----------------------------
# Hyprland dynamic colors
# -----------------------------
accent="${color2#\#}"
accent2="${color6#\#}"
dark="${color0#\#}"

cat > "$WAL_CACHE/hyprland.conf" <<EOF2
general {
    col.active_border = rgba(${accent}ff)
    col.inactive_border = rgba(${dark}aa)
}
EOF2

hyprctl reload >/dev/null 2>&1 || true

# -----------------------------
# Firefox userChrome pywal colors
# -----------------------------
cat > "$WAL_CACHE/firefox.css" <<EOF2
:root {
  --wal-bg: ${background} !important;
  --wal-fg: ${foreground} !important;
  --wal-panel: ${color0} !important;
  --wal-accent: ${color2} !important;
  --wal-accent2: ${color6} !important;
  --wal-critical: ${color1} !important;
  --wal-warning: ${color3} !important;
}
EOF2

# -----------------------------
# Waybar GTK CSS
# -----------------------------
cat > "$WAL_CACHE/waybar.css" <<EOF2
@define-color wal_bg ${background};
@define-color wal_fg ${foreground};
@define-color wal_accent ${color2};
@define-color wal_accent2 ${color6};
@define-color wal_dark ${color0};
@define-color wal_warning ${color3};
@define-color wal_critical ${color1};
EOF2

# -----------------------------
# Wofi GTK CSS colors
# -----------------------------
cat > "$WAL_CACHE/wofi.css" <<EOF2
@define-color wal_bg ${background};
@define-color wal_fg ${foreground};
@define-color wal_accent ${color2};
@define-color wal_accent2 ${color6};
@define-color wal_dark ${color0};
@define-color wal_warning ${color3};
@define-color wal_critical ${color1};
EOF2

# -----------------------------
# GTK 3 / GTK 4 CSS
# -----------------------------
cat > "$WAL_CACHE/gtk.css" <<EOF2
@define-color theme_bg_color ${background};
@define-color theme_fg_color ${foreground};
@define-color theme_base_color ${background};
@define-color theme_text_color ${foreground};
@define-color theme_selected_bg_color ${color2};
@define-color theme_selected_fg_color ${foreground};
@define-color accent_bg_color ${color2};
@define-color accent_fg_color ${foreground};
@define-color window_bg_color ${background};
@define-color window_fg_color ${foreground};
@define-color view_bg_color ${background};
@define-color view_fg_color ${foreground};
@define-color card_bg_color ${color0};
@define-color headerbar_bg_color ${background};
@define-color headerbar_fg_color ${foreground};

* {
    caret-color: ${color6};
}

window,
dialog,
popover,
.background {
    background-color: ${background};
    color: ${foreground};
}

button,
entry,
textview,
treeview,
list,
row {
    background-color: ${color0};
    color: ${foreground};
}

button:hover,
row:hover {
    background-color: ${color2};
    color: ${foreground};
}

selection {
    background-color: ${color2};
    color: ${foreground};
}
EOF2

# -----------------------------
# Kitty colors
# -----------------------------
cat > "$WAL_CACHE/kitty.conf" <<EOF2
background ${background}
foreground ${foreground}
cursor ${color6}
selection_background ${color2}
selection_foreground ${background}

color0 ${color0}
color1 ${color1}
color2 ${color2}
color3 ${color3}
color4 ${color4}
color5 ${color5}
color6 ${color6}
color7 ${color7}
color8 ${color8}
color9 ${color9}
color10 ${color10}
color11 ${color11}
color12 ${color12}
color13 ${color13}
color14 ${color14}
color15 ${color15}
EOF2

# -----------------------------
# Mako dynamic config
# -----------------------------
cat > "$WAL_CACHE/mako.conf" <<EOF2
font=JetBrains Mono 11
background-color=${background}dd
text-color=${foreground}
border-color=${color2}
border-size=1
border-radius=14
padding=12
margin=12
width=360
height=120
default-timeout=5000
anchor=top-right

[urgency=low]
border-color=${color0}

[urgency=normal]
border-color=${color2}

[urgency=high]
border-color=${color1}
default-timeout=0
EOF2

# -----------------------------
# Reload apps
# -----------------------------
pkill mako >/dev/null 2>&1 || true
mako -c "$WAL_CACHE/mako.conf" >/dev/null 2>&1 &

pkill waybar >/dev/null 2>&1 || true
waybar > "$WAYBAR_LOG" 2>&1 &

# Existing Kitty windows do not always live-reload colors.
# New Kitty windows will use the generated colors.
