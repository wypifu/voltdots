#!/usr/bin/env bash
# voltdots — battery_notify.sh
# Battery level notifications
# Run as a daemon via execs.conf

NOTIFIED_20=false
NOTIFIED_10=false
NOTIFIED_5=false

while true; do
    # Check if battery exists
    BAT=$(ls /sys/class/power_supply/ | grep -i "bat" | head -1)
    [[ -z "$BAT" ]] && sleep 60 && continue

    CAPACITY=$(cat /sys/class/power_supply/$BAT/capacity 2>/dev/null)
    STATUS=$(cat /sys/class/power_supply/$BAT/status 2>/dev/null)

    # Reset notifications when charging
    if [[ "$STATUS" == "Charging" ]]; then
        NOTIFIED_20=false
        NOTIFIED_10=false
        NOTIFIED_5=false
    fi

    if [[ "$STATUS" != "Charging" ]]; then
        if [[ $CAPACITY -le 5 ]] && [[ "$NOTIFIED_5" == false ]]; then
            notify-send "󰁺 Battery Critical" "${CAPACITY}% — plug in now!" \
                -u critical -t 0 -a "Battery"
            NOTIFIED_5=true
        elif [[ $CAPACITY -le 10 ]] && [[ "$NOTIFIED_10" == false ]]; then
            notify-send "󰁻 Battery Low" "${CAPACITY}% remaining" \
                -u critical -t 10000 -a "Battery"
            NOTIFIED_10=true
        elif [[ $CAPACITY -le 20 ]] && [[ "$NOTIFIED_20" == false ]]; then
            notify-send "󰁼 Battery Warning" "${CAPACITY}% remaining" \
                -u normal -t 8000 -a "Battery"
            NOTIFIED_20=true
        fi
    fi

    sleep 60
done
