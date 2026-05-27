#!/usr/bin/env bash

chosen=$(printf "  Lock\n󰍃  Logout\n󰜉  Reboot\n  Shutdown" | \
    wofi --dmenu \
         --prompt "Power" \
         --width 360 \
         --height 300 \
         --location center \
         --style "$HOME/.config/wofi/power.css")

case "$chosen" in
    "  Lock")
        hyprlock
        ;;
    "󰍃  Logout")
        hyprctl dispatch exit
        ;;
    "󰜉  Reboot")
        systemctl reboot
        ;;
    "  Shutdown")
        systemctl poweroff
        ;;
esac
