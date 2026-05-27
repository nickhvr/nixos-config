#!/usr/bin/env bash

mkdir -p "$HOME/Pictures/Screenshots"

file="$HOME/Pictures/Screenshots/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"

grim -g "$(slurp)" "$file" && swappy -f "$file"
