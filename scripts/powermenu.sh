#!/usr/bin/env bash
# voltdots — powermenu.sh
# Power menu via rofi

confirm() {
    local msg="$1"
    local choice
    choice=$(printf "$msg\n───────────────\n󰄬  Confirm\n󰅖  Cancel" | wofi --dmenu \
    --style "$HOME/.voltdots/wofi/style.css" \
    --width 320 --height 200 \
    --location 2 \
    --hide-search)
[[ "$choice" == *"Confirm"* ]]
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
