#!/usr/bin/env bash
# voltdots — powermenu.sh

confirm() {
    local msg="$1"
    local choice
    choice=$(printf "$msg\n───────────────\n󰄬  Confirm\n󰅖  Cancel" | wofi --dmenu \
        --style "$HOME/.voltdots/wofi/style.css" \
        --width 320 --height 200 \
        --location 2)
    [[ "$choice" == *"Confirm"* ]]
}

# Handle direct argument
if [[ -n "$1" ]]; then
    case "$1" in
        logout)   if confirm "󰍃 Logout?";   then hyprctl dispatch exit; fi; exit 0 ;;
        reboot)   if confirm "󰜉 Reboot?";   then systemctl reboot; fi; exit 0 ;;
        shutdown) if confirm "󰐥 Shutdown?"; then systemctl poweroff; fi; exit 0 ;;
        suspend)  if confirm "󰒲 Suspend?";  then systemctl suspend; fi; exit 0 ;;
    esac
fi

OPTIONS="󰌾  Lock\n󰍃  Logout\n󰒲  Suspend\n󰋊  Hibernate\n󰜉  Reboot\n󰐥  Shutdown\n󰅖  Cancel"

CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu \
    --prompt "Power" \
    --style "$HOME/.voltdots/wofi/style.css" \
    --width 280 --height 320)

case "$CHOICE" in
    *"Lock"*)      hyprlock ;;
    *"Logout"*)    if confirm "󰍃 Logout?";   then hyprctl dispatch exit; fi ;;
    *"Suspend"*)   if confirm "󰒲 Suspend?";  then systemctl suspend; fi ;;
    *"Hibernate"*) if confirm "󰋊 Hibernate?"; then systemctl hibernate; fi ;;
    *"Reboot"*)    if confirm "󰜉 Reboot?";   then systemctl reboot; fi ;;
    *"Shutdown"*)  if confirm "󰐥 Shutdown?"; then systemctl poweroff; fi ;;
    *"Cancel"*|"") exit 0 ;;
esac
