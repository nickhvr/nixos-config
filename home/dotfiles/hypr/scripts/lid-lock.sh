#!/usr/bin/env bash

export XDG_RUNTIME_DIR="/run/user/$(id -u nick)"
export HYPRLAND_INSTANCE_SIGNATURE="$(ls -1 "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -n 1)"

if pgrep -u nick hyprlock >/dev/null 2>&1; then
    exit 0
fi

sudo -u nick XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_INSTANCE_SIGNATURE" hyprlock
