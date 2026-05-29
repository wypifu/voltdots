#!/usr/bin/env bash
# voltdots — powerprofile.sh
# Switch power profile
# Supports: ACPI platform_profile (desktop/modern laptop) and TLP (older laptop)

PROFILE_FILE="/sys/firmware/acpi/platform_profile"
TLP_AVAILABLE=$(command -v tlp > /dev/null 2>&1 && echo "yes" || echo "no")

# --- Not supported ---
if [[ ! -f "$PROFILE_FILE" ]] && [[ "$TLP_AVAILABLE" == "no" ]]; then
    notify-send "Energy" "Power profiles not supported on this machine" -a "Power"
    exit 0
fi

# --- TLP fallback ---
if [[ ! -f "$PROFILE_FILE" ]] && [[ "$TLP_AVAILABLE" == "yes" ]]; then
    CHOICE=$(printf "󰓅  Performance\n󰾅  Balanced\n󰾆  Power saver" | wofi --dmenu \
        --prompt "Power profile (via TLP)" \
        --style "$HOME/.voltdots/wofi/style.css" \
        --width 300 --height 160)

    case "$CHOICE" in
        *"Performance"*)
            sudo tlp ac
            notify-send "Energy" "Performance mode" -a "Power" ;;
        *"Balanced"*)
            sudo tlp bat
            notify-send "Energy" "Balanced mode" -a "Power" ;;
        *"Power saver"*)
            sudo tlp bat
            notify-send "Energy" "Power saver mode" -a "Power" ;;
        *) exit 0 ;;
    esac
    exit 0
fi

# --- ACPI platform profile ---
CURRENT=$(cat "$PROFILE_FILE" 2>/dev/null || echo "unknown")

CHOICE=$(printf "󰓅  Performance\n󰾅  Balanced\n󰾆  Power saver" | wofi --dmenu \
    --prompt "Power profile (current: $CURRENT)" \
    --style "$HOME/.voltdots/wofi/style.css" \
    --width 300 --height 160)

case "$CHOICE" in
    *"Performance"*)
        echo "performance" | sudo tee "$PROFILE_FILE" > /dev/null
        notify-send "Energy" "Performance mode" -a "Power" ;;
    *"Balanced"*)
        echo "balanced" | sudo tee "$PROFILE_FILE" > /dev/null
        notify-send "Energy" "Balanced mode" -a "Power" ;;
    *"Power saver"*)
        echo "low-power" | sudo tee "$PROFILE_FILE" > /dev/null
        notify-send "Energy" "Power saver mode" -a "Power" ;;
    *) exit 0 ;;
esac
