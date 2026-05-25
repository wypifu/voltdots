#!/usr/bin/env bash
# voltdots — actioncenter.sh
# Action center panel via rofi
# Shows volume, brightness, wifi, bluetooth, audio output, power options
# Handle direct calls with argument
# Load defaults
CUSTOM="$HOME/.voltdots/hypr/custom/defaults.conf"
DEFAULT="$HOME/.voltdots/hypr/default/defaults.conf"
[[ -f "$CUSTOM" ]] && source "$CUSTOM" || source "$DEFAULT"

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

# --- Helpers ---
get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}'
}

get_mute() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "yes" || echo "no"
}

get_brightness() {
    brightnessctl get 2>/dev/null | awk -v max="$(brightnessctl max)" '{printf "%d", ($1/max)*100}'
}

get_wifi_status() {
    nmcli -t -f WIFI g | grep -q enabled && echo "on" || echo "off"
}

get_wifi_ssid() {
    nmcli -t -f NAME,DEVICE c show --active 2>/dev/null | grep wifi | cut -d: -f1 | head -1
}

get_bt_status() {
    bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && echo "on" || echo "off"
}

get_bt_device() {
    bluetoothctl info 2>/dev/null | grep "Name:" | head -1 | awk '{print $2}'
}

get_audio_sink() {
    wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep "node.nick" | cut -d'"' -f2 | head -c 20
}

# --- Build menu ---
build_menu() {
    local vol=$(get_volume)
    local mute=$(get_mute)
    local bright=$(get_brightness)
    local wifi=$(get_wifi_status)
    local ssid=$(get_wifi_ssid)
    local bt=$(get_bt_status)
    local bt_dev=$(get_bt_device)
    local sink=$(get_audio_sink)

    # Volume icon
    local vol_icon
    if [[ "$mute" == "yes" ]]; then
        vol_icon="󰝟"
    elif [[ $vol -gt 66 ]]; then
        vol_icon="󰕾"
    elif [[ $vol -gt 33 ]]; then
        vol_icon="󰖀"
    else
        vol_icon="󰕿"
    fi

    # Wifi icon
    local wifi_icon
    [[ "$wifi" == "on" ]] && wifi_icon="󰤨" || wifi_icon="󰤭"
    local wifi_label="${ssid:-Disconnected}"

    # Bluetooth icon
    local bt_icon
    [[ "$bt" == "on" ]] && bt_icon="󰂯" || bt_icon="󰂲"
    local bt_label="${bt_dev:-Disconnected}"

    echo "$vol_icon  Volume: ${vol}%"
    echo "󰃠  Brightness: ${bright}%"
    echo "───────────────────────"
    echo "$wifi_icon  WiFi: $wifi_label"
    echo "  WiFi networks..."
    echo "───────────────────────"
    echo "$bt_icon  Bluetooth: $bt_label"
    echo "  Bluetooth devices..."
    echo "───────────────────────"
    echo "󰶈  Rotate left"
    echo "󰶊  Rotate right"
    echo "󰁌  Auto-rotate"
    echo "───────────────────────"
    echo "󰓃  Audio output: $sink"
    echo "  Audio outputs..."
    echo "───────────────────────"
    echo "󰌾  Lock"
    echo "󰍃  Logout"
    echo "󰒲  Suspend"
    echo "󰜉  Reboot"
    echo "󰐥  Shutdown"
}

# --- WiFi submenu ---
wifi_menu() {
    local status=$(get_wifi_status)

    if [[ "$status" == "on" ]]; then
        # Scan networks
        local networks
        networks=$(nmcli -t -f SSID,SIGNAL,SECURITY d wifi list 2>/dev/null | \
            awk -F: '{printf "󰤨  %-30s %s%%  %s\n", $1, $2, $3}' | head -10)
        local choice
        choice=$(echo -e "󰌍  Go back\n󰤭  Disable WiFi\n───────────────────────\n$networks" | \
            wofi --dmenu -p "WiFi" --style /home/wypifu/.voltdots/wofi/style.css)

        case "$choice" in
            *"Go back"*)
                if [[ "$FROM_SWAYNC" == true ]]; then
                    exit 0
                else
                    ~/.voltdots/scripts/actioncenter.sh; exit 0
                fi ;;
            *"Disable WiFi"*)
                nmcli radio wifi off
                notify-send "WiFi" "Disabled" -a "Action Center"
                ;;
            󰤨*)
                local ssid=$(echo "$choice" | awk '{print $2}')
                nmcli d wifi connect "$ssid" 2>/dev/null && \
                    notify-send "WiFi" "Connected to $ssid" -a "Action Center" || \
                    notify-send "WiFi" "Failed to connect to $ssid" -a "Action Center"
                ;;
        esac
    else
        nmcli radio wifi on
        notify-send "WiFi" "Enabled" -a "Action Center"
    fi
}

# --- Bluetooth submenu ---
bt_menu() {
    local status=$(get_bt_status)

    if [[ "$status" == "on" ]]; then
        local devices
        devices=$(bluetoothctl devices 2>/dev/null | \
            awk '{print "󰂯  " $3}' | head -10)
        local choice
        choice=$(echo -e "󰌍  Go back\n󰂲  Disable Bluetooth\n───────────────────────\n$devices" | \
            wofi --dmenu -p "Bluetooth" --style /home/wypifu/.voltdots/wofi/style.css)

        case "$choice" in
            *"Go back"*)
                if [[ "$FROM_SWAYNC" == true ]]; then
                    exit 0
                else
                    ~/.voltdots/scripts/actioncenter.sh; exit 0
                fi ;;
            *"Disable Bluetooth"*)
                bluetoothctl power off
                notify-send "Bluetooth" "Disabled" -a "Action Center"
                ;;
            󰂯*)
                local dev=$(echo "$choice" | awk '{print $2}')
                bluetoothctl connect "$dev" 2>/dev/null && \
                    notify-send "Bluetooth" "Connected to $dev" -a "Action Center"
                ;;
        esac
    else
        bluetoothctl power on
        notify-send "Bluetooth" "Enabled" -a "Action Center"
    fi
}

# --- Audio output submenu ---
audio_menu() {
    local sinks
    sinks=$(wpctl status 2>/dev/null | grep -A 20 "Audio" | grep "Sinks" -A 10 | \
        grep "│" | awk '{print "󰓃  " $0}' | head -10)

    local choice
    choice=$(echo -e "󰌍  Go back\n───────────────────────\n$sinks" | wofi --dmenu \
        --style "$HOME/.voltdots/wofi/style.css" --width 450 --height 300)

    case "$choice" in
        *"Go back"*)
            if [[ "$FROM_SWAYNC" == true ]]; then
                exit 0
            else
                ~/.voltdots/scripts/actioncenter.sh; exit 0
            fi ;;
        *)
            if [[ -n "$choice" ]]; then
                local sink_id=$(echo "$choice" | grep -o '[0-9]*\.' | head -1 | tr -d '.')
                [[ -n "$sink_id" ]] && wpctl set-default "$sink_id" && \
                    notify-send "Audio" "Output changed" -a "Action Center"
            fi
            ;;
    esac
}

# --- Volume submenu ---
volume_menu() {
    local choice
    choice=$(printf "󰌍  Go back\n󰕾  Volume +10%%\n󰕿  Volume -10%%\n󰝟  Toggle mute" | \
        wofi --dmenu -p "Volume" --style /home/wypifu/.voltdots/wofi/style.css)

    case "$choice" in
        *"Go back"*)
            if [[ "$FROM_SWAYNC" == true ]]; then
                exit 0
            else
                ~/.voltdots/scripts/actioncenter.sh; exit 0
            fi ;;
        *"+10%"*)
            swayosd-client --output-volume raise
            ;;
        *"-10%"*)
            swayosd-client --output-volume lower
            ;;
        *"mute"*)
            swayosd-client --output-volume mute-toggle
            ;;
    esac
}

# --- Brightness submenu ---
brightness_menu() {
    local choice
    choice=$(printf "󰌍  Go back\n󰃠  Brightness +10%%\n󰃞  Brightness -10%%" | \
        wofi --dmenu -p "Brightness" --style /home/wypifu/.voltdots/wofi/style.css)

    case "$choice" in
        *"Go back"*)
            if [[ "$FROM_SWAYNC" == true ]]; then
                exit 0
            else
                ~/.voltdots/scripts/actioncenter.sh; exit 0
            fi ;;
        *"+10%"*)
            swayosd-client --brightness raise
            ;;
        *"-10%"*)
            swayosd-client --brightness lower
            ;;
    esac
}

# Handle direct calls with argument
if [[ -n "$1" ]]; then
    FROM_SWAYNC=true
    case "$1" in
        wifi)  wifi_menu; exit 0 ;;
        bt)    bt_menu; exit 0 ;;
        audio) audio_menu; exit 0 ;;
    esac
fi

# --- Main ---
CHOICE=$(build_menu | wofi --dmenu \
    -p "  Action Center" \
    --style "$HOME/.voltdots/wofi/style.css" \
    --yoffset 0 \
    --width 300 \
    --height 640)

case "$CHOICE" in
    *"Volume"*)         ~/.voltdots/scripts/volumectl.sh ;;
    *"Brightness"*)     ~/.voltdots/scripts/volumectl.sh ;;
    *"WiFi networks"*)  wifi_menu ;;
    *"WiFi:"*)          wifi_menu ;;
    *"Bluetooth dev"*)  bt_menu ;;
    *"Bluetooth:"*)     bt_menu ;;
    *"Rotate left"*)    ~/.voltdots/scripts/rotate.sh left ;;
    *"Rotate right"*)   ~/.voltdots/scripts/rotate.sh right ;;
    *"Auto-rotate"*)    ~/.voltdots/scripts/rotate.sh auto & ;;
    *"Audio outputs"*)  audio_menu ;;
    *"Lock"*)           hyprlock ;;
    *"Logout"*)   if confirm "󰍃 Logout — are you sure?";   then hyprctl dispatch exit; fi ;;
    *"Suspend"*)  if confirm "󰒲 Suspend — are you sure?";  then systemctl suspend; fi ;;
    *"Reboot"*)   if confirm "󰜉 Reboot — are you sure?";   then systemctl reboot; fi ;;
    *"Shutdown"*) if confirm "󰐥 Shutdown — are you sure?"; then systemctl poweroff; fi ;;
esac
