#!/usr/bin/env bash
# voltdots — volumectl.sh
# Volume/brightness control via rofi

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}'
}

get_mute() {
     wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED \
        && echo "󰝟  Currently muted — click to unmute" \
        || echo "󰕾  Currently unmuted — click to mute"
}

get_brightness() {
    brightnessctl get | awk -v max="$(brightnessctl max)" '{printf "%d", ($1/max)*100}'
}

while true; do
    VOL=$(get_volume)
    MUTE=$(get_mute)
    BRIGHT=$(get_brightness)

    CHOICE=$(printf \
" 󰌍  Go back
󰕾  Volume:     ${VOL}%%
󰁝  Vol  +10%%
󰁅  Vol  -10%%
${MUTE}
───────────────
󰃠  Brightness: ${BRIGHT}%%
󰃟  Bright +10%%
󰃞  Bright -10%%" \
    | wofi --dmenu \
        -p "󰎇 Controls" \
         \
        --style /home/wypifu/.voltdots/wofi/style.css)
    case "$CHOICE" in
        *"Go back"*)
            ~/.voltdots/scripts/actioncenter.sh
            exit 0
            ;;
        *"Vol  +10%"*)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+ --limit 1.0
            VOL_PCT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.2f", $2}')
            swayosd-client --custom-icon audio-volume-high-symbolic --custom-progress $VOL_PCT
            ;;
        *"Vol  -10%"*)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-
            VOL_PCT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.2f", $2}')
            swayosd-client --custom-icon audio-volume-high-symbolic --custom-progress $VOL_PCT
            ;;
        *"click to"*)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            swayosd-client --output-volume 0
            ;;
        *"Bright +10%"*)
            brightnessctl set 10%+
            BRIGHT_PCT=$(brightnessctl get | awk -v max="$(brightnessctl max)" '{printf "%.2f", $1/max}')
            swayosd-client --custom-icon display-brightness-symbolic --custom-progress $BRIGHT_PCT
            ;;
        *"Bright -10%"*)
            brightnessctl set 10%-
            BRIGHT_PCT=$(brightnessctl get | awk -v max="$(brightnessctl max)" '{printf "%.2f", $1/max}')
            swayosd-client --custom-icon display-brightness-symbolic --custom-progress $BRIGHT_PCT
            ;;
        *)
            exit 0
            ;;
    esac
    # Loop back to refresh values after each action
done
