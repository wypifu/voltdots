#!/usr/bin/env bash
# voltdots — switchwall.sh
# Wallpaper switcher using swww
# Usage: switchwall.sh          — change once (manual/keybind)
#        switchwall.sh --init   — startup: load last/fallback, start daemon if auto enabled
#        switchwall.sh --daemon — loop with delay (force auto regardless of config)

# Load defaults
CUSTOM="$HOME/.voltdots/hypr/custom/defaults.conf"
DEFAULT="$HOME/.voltdots/hypr/default/defaults.conf"
[[ -f "$CUSTOM" ]] && source "$CUSTOM" || source "$DEFAULT"

WALLPAPER_DIR="${VOLT_WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
WALLPAPER_FALLBACK="${VOLT_WALLPAPER_FALLBACK:-$HOME/.voltdots/themes/bkpview/wallpaper.png}"
WALLPAPER_AUTO="${VOLT_WALLPAPER_AUTO:-false}"
DELAY="${VOLT_WALLPAPER_DELAY:-900}"
LAST_WALL_FILE="/tmp/voltdots_last_wall"

TRANSITIONS=(fade grow outer wave slide)

get_random_wall() {
    local wall
    wall=$(find "$WALLPAPER_DIR" -maxdepth 2 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        2>/dev/null | shuf -n1)

    # Fallback if dir empty or not found
    if [[ -z "$wall" ]]; then
        if [[ -f "$WALLPAPER_FALLBACK" ]]; then
            wall="$WALLPAPER_FALLBACK"
        else
            notify-send "Wallpaper" "No images found and no fallback available" -a "Wallpaper"
            exit 1
        fi
    fi
    echo "$wall"
}

get_random_transition() {
    echo "${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}"
}

apply_wall() {
    local wall="$1"
    local transition="${2:-$(get_random_transition)}"

    awww img "$wall" \
        --transition-type "$transition" \
        --transition-duration 1.5 \
        --transition-fps 60

    # Save last wall
    echo "$wall" > "$LAST_WALL_FILE"
}

switch_once() {
    local wall
    wall=$(get_random_wall)
    apply_wall "$wall"
    notify-send "Wallpaper changed" "$(basename "$wall")" -a "Wallpaper"
}

run_daemon() {
    while true; do
        switch_once
        sleep "$DELAY"
    done
}

# --- Main ---
case "$1" in
    --init)
        # Wait for awww-daemon
        awww query || { awww-daemon & sleep 1; }

        # Load last wall if exists, otherwise random/fallback
        if [[ -f "$LAST_WALL_FILE" ]] && [[ -f "$(cat "$LAST_WALL_FILE")" ]]; then
            apply_wall "$(cat "$LAST_WALL_FILE")" fade
        else
            apply_wall "$(get_random_wall)" fade
        fi

        # Start auto daemon if enabled
        if [[ "$WALLPAPER_AUTO" == "true" ]]; then
            sleep "$DELAY" && ~/.voltdots/scripts/switchwall.sh --daemon &
        fi
        ;;
    --daemon)
        run_daemon
        ;;
    *)
        # Manual switch
        switch_once
        ;;
esac
