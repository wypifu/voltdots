#!/usr/bin/env bash
# Confirm before closing protected apps

PROTECTED="firefox|thunar|nautilus|ghostty|foot|kitty|gnome-terminal|terminator"
ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r '.class')

if echo "$ACTIVE_CLASS" | grep -qiE "$PROTECTED"; then
    response=$(printf "No\nYes" | wofi --dmenu -p "Close $ACTIVE_CLASS ?")
    [[ "$response" == "Yes" ]] && hyprctl dispatch killactive
else
    hyprctl dispatch killactive
fi
