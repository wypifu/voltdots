#!/usr/bin/env bash
# voltdots — powermenu.sh
# Power menu via rofi

confirm() {
    local msg="$1"
    local choice
    choice=$(printf "Yes\nNo" | wofi --dmenu \
        --prompt "$msg" \
        --style "$HOME/.voltdots/wofi/style.css" \
        --width 200 --height 120 \
        --hide-search)
    [[ "$choice" == "Yes" ]]
}


OPTIONS="  Lock\n  Logout\n  Suspend\n  Hibernate\n  Reboot\n  Shutdown\n  Cancel"

CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu \
    -p "Power" \
    -i \
     \
    --style /home/wypifu/.voltdots/wofi/style.css)

case "$CHOICE" in
    *Lock)
        hyprlock
        ;;
    *Logout)
        if confirm "Logout?"; then
          sleep 1.0
          hyprctl dispatch exit
        fi
        ;;
    *Suspend)
        confirm "Suspend?" && systemctl suspend
        ;;
    *Hibernate)
        confirm "Hibernate?" && systemctl hibernate
        ;;
    *Reboot)
        confirm "Reboot?" && systemctl reboot
        ;;
    *Shutdown)
        confirm "Shutdown?" && systemctl poweroff
        ;;
    *Cancel|"")
        exit 0
        ;;
esac
