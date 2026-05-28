#!/usr/bin/env bash

chosen=$(printf "󰨞  VS Code\n󰊻  Teams\n  Firefox\n  Kitty" | \
    wofi --dmenu \
         --prompt "Apps" \
         --width 380 \
         --height 340 \
         --location center \
         --style "$HOME/.config/wofi/power.css")

case "$chosen" in
    "󰨞  VS Code")
        code
        ;;
    "󰊻  Teams")
        teams-for-linux
        ;;
    "  Firefox")
        firefox
        ;;
    "  Kitty")
        kitty
        ;;
esac
