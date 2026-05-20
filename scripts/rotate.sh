#!/usr/bin/env bash
# voltdots — rotate.sh
# Screen rotation and auto-rotate
# Usage: rotate.sh left|right|auto

MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')
STATE_FILE="/tmp/voltdots_autorotate"

map_input() {
    local transform="$1"
    local t

    case "$transform" in
        normal) t=0 ;;
        90)     t=1 ;;
        180)    t=2 ;;
        270)    t=3 ;;
    esac

    # Touchscreen
    hyprctl keyword input:touchdevice:transform $t

    # Note: touchpad rotation not supported in Hyprland
    # Use device physically or wait for upstream support
}

get_transform() {
    wlr-randr 2>/dev/null | awk "/^$MONITOR /{found=1} found && /Transform:/{print \$2; exit}" 
}

switch_waybar() {
    local mode="$1"
    if [[ "$mode" == "portrait" ]]; then
        sleep 0.3 && pkill waybar && waybar --config "$HOME/.voltdots/waybar/portrait/config.jsonc" &
    else
        sleep 0.3 && pkill waybar && waybar --config "$HOME/.voltdots/waybar/default/config.jsonc" &
    fi
}

rotate_left() {
    local current=$(get_transform)
    case "$current" in
        normal) wlr-randr --output "$MONITOR" --transform 270; map_input 270; switch_waybar portrait ;;
        90)     wlr-randr --output "$MONITOR" --transform normal; map_input normal; switch_waybar landscape ;;
        180)    wlr-randr --output "$MONITOR" --transform 90; map_input 90; switch_waybar portrait ;;
        270)    wlr-randr --output "$MONITOR" --transform 180; map_input 180; switch_waybar portrait ;;
        *)      wlr-randr --output "$MONITOR" --transform 270; map_input 270; switch_waybar portrait ;;
    esac
}

rotate_right() {
    local current=$(get_transform)
    case "$current" in
        normal) wlr-randr --output "$MONITOR" --transform 90; map_input 90; switch_waybar portrait ;;
        90)     wlr-randr --output "$MONITOR" --transform 180; map_input 180; switch_waybar portrait ;;
        180)    wlr-randr --output "$MONITOR" --transform 270; map_input 270; switch_waybar portrait ;;
        270)    wlr-randr --output "$MONITOR" --transform normal; map_input normal; switch_waybar landscape ;;
        *)      wlr-randr --output "$MONITOR" --transform 90; map_input 90; switch_waybar portrait ;;
    esac
}

autorotate() {
    if ! command -v monitor-sensor > /dev/null; then
        exit 0
    fi

    if [[ -f "$STATE_FILE" ]]; then
        rm "$STATE_FILE"
        notify-send "Auto-rotate" "Disabled" -a "Rotate"
        pkill -f "monitor-sensor"
        exit 0
    fi

    touch "$STATE_FILE"
    notify-send "Auto-rotate" "Enabled" -a "Rotate"

    monitor-sensor 2>/dev/null | while read -r line; do
        [[ -f "$STATE_FILE" ]] || break
        case "$line" in
            *"normal"*)    wlr-randr --output "$MONITOR" --transform normal; map_input normal; switch_waybar landscape ;;
            *"bottom-up"*) wlr-randr --output "$MONITOR" --transform 180;   map_input 180;   switch_waybar portrait ;;
            *"right-up"*)  wlr-randr --output "$MONITOR" --transform 90;    map_input 90;    switch_waybar portrait ;;
            *"left-up"*)   wlr-randr --output "$MONITOR" --transform 270;   map_input 270;   switch_waybar portrait ;;
        esac
    done
}

case "$1" in
    left)  rotate_left ;;
    right) rotate_right ;;
    auto)  autorotate ;;
    *)     echo "Usage: rotate.sh left|right|auto" >&2; exit 1 ;;
esac
