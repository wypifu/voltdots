#!/usr/bin/env bash
# voltdots — powermenu.sh
# Power menu via rofi

OPTIONS="  Lock\n  Logout\n  Suspend\n  Hibernate\n  Reboot\n  Shutdown\n  Cancel"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu \
    -p "Power" \
    -i \
    -no-custom \
    -theme-str 'window {width: 250px;}')

case "$CHOICE" in
    *Lock)
        hyprlock
        ;;
    *Logout)
        hyprctl dispatch exit
        ;;
    *Suspend)
        systemctl suspend
        ;;
    *Hibernate)
        systemctl hibernate
        ;;
    *Reboot)
        systemctl reboot
        ;;
    *Shutdown)
        systemctl poweroff
        ;;
    *Cancel|"")
        exit 0
        ;;
esac
