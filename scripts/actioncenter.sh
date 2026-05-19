#!/usr/bin/env bash
# voltdots — actioncenter.sh
# Action center panel via rofi
# Shows volume, brightness, wifi, bluetooth, audio output, power options

# Load defaults
CUSTOM="$HOME/.voltdots/hypr/custom/defaults.conf"
DEFAULT="$HOME/.voltdots/hypr/default/defaults.conf"
[[ -f "$CUSTOM" ]] && source "$CUSTOM" || source "$DEFAULT"

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
        choice=$(echo -e "󰤭  Disable WiFi\n───────────────────────\n$networks" | \
            rofi -dmenu -p "WiFi" -theme-str 'window {width: 400px;}')

        case "$choice" in
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
        choice=$(echo -e "󰂲  Disable Bluetooth\n───────────────────────\n$devices" | \
            rofi -dmenu -p "Bluetooth" -theme-str 'window {width: 400px;}')

        case "$choice" in
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
    choice=$(echo "$sinks" | rofi -dmenu -p "Audio output" \
        -theme-str 'window {width: 450px;}')

    if [[ -n "$choice" ]]; then
        local sink_id=$(echo "$choice" | grep -o '[0-9]*\.' | head -1 | tr -d '.')
        [[ -n "$sink_id" ]] && wpctl set-default "$sink_id" && \
            notify-send "Audio" "Output changed" -a "Action Center"
    fi
}

# --- Volume submenu ---
volume_menu() {
    local choice
    choice=$(printf "󰕾  Volume +10%%\n󰕿  Volume -10%%\n󰝟  Toggle mute" | \
        rofi -dmenu -p "Volume" -theme-str 'window {width: 300px;}')

    case "$choice" in
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
    choice=$(printf "󰃠  Brightness +10%%\n󰃞  Brightness -10%%" | \
        rofi -dmenu -p "Brightness" -theme-str 'window {width: 300px;}')

    case "$choice" in
        *"+10%"*)
            swayosd-client --brightness raise
            ;;
        *"-10%"*)
            swayosd-client --brightness lower
            ;;
    esac
}

# --- Main ---
CHOICE=$(build_menu | rofi -dmenu \
    -p "  Action Center" \
    -no-custom \
    -theme-str 'window {width: 350px;} listview {lines: 18;}')

case "$CHOICE" in
    *"Volume"*)         volume_menu ;;
    *"Brightness"*)     brightness_menu ;;
    *"WiFi networks"*)  wifi_menu ;;
    *"WiFi:"*)          wifi_menu ;;
    *"Bluetooth dev"*)  bt_menu ;;
    *"Bluetooth:"*)     bt_menu ;;
    *"Audio outputs"*)  audio_menu ;;
    *"Lock"*)           hyprlock ;;
    *"Logout"*)         hyprctl dispatch exit ;;
    *"Suspend"*)        systemctl suspend ;;
    *"Reboot"*)         systemctl reboot ;;
    *"Shutdown"*)       systemctl poweroff ;;
esac
