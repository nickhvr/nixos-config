#!/usr/bin/env bash

LOG="/tmp/wallpaper-picker-waybar.log"

(
    export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH"
    "$HOME/.config/hypr/scripts/wallpaper-picker.sh"
) >>"$LOG" 2>&1 &
