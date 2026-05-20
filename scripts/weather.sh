#!/usr/bin/env bash
# voltdots — weather.sh
# Fetch weather data from wttr.in and display in waybar or rofi popup
# Usage: weather.sh --short   — one line for waybar
#        weather.sh --popup   — detailed popup via rofi

# Load defaults
CUSTOM="$HOME/.voltdots/hypr/custom/defaults.conf"
DEFAULT="$HOME/.voltdots/hypr/default/defaults.conf"
[[ -f "$CUSTOM" ]] && source "$CUSTOM" || source "$DEFAULT"

CITY="${VOLT_WEATHER_CITY:-Beijing}"
CITY2="${VOLT_WEATHER_CITY2:-Lille}"
UNIT="${VOLT_WEATHER_UNIT:-metric}"
CACHE_DIR="/tmp/voltdots_weather"
CACHE_TTL=600  # 10 minutes

mkdir -p "$CACHE_DIR"

# --- Unit flag for wttr.in ---
[[ "$UNIT" == "metric" ]] && UNIT_FLAG="m" || UNIT_FLAG="u"

# --- Fetch with cache ---
fetch_weather() {
    local city="$1"
    local cache_file="$CACHE_DIR/${city// /_}.json"

    # Use cache if fresh
    if [[ -f "$cache_file" ]]; then
        local age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        [[ $age -lt $CACHE_TTL ]] && cat "$cache_file" && return
    fi

    # Fetch from wttr.in
    local data
    data=$(curl -sf --max-time 5 "wttr.in/${city// /+}?format=j1&${UNIT_FLAG}" 2>/dev/null)

    if [[ -n "$data" ]]; then
        echo "$data" > "$cache_file"
        echo "$data"
    elif [[ -f "$cache_file" ]]; then
        # Return stale cache on error
        cat "$cache_file"
    else
        echo ""
    fi
}

# --- Parse weather data ---
parse_weather() {
    local data="$1"
    local temp desc feels wind humidity icon

    temp=$(echo "$data" | jq -r '.current_condition[0].temp_C' 2>/dev/null)
    feels=$(echo "$data" | jq -r '.current_condition[0].FeelsLikeC' 2>/dev/null)
    desc=$(echo "$data" | jq -r '.current_condition[0].weatherDesc[0].value' 2>/dev/null)
    wind=$(echo "$data" | jq -r '.current_condition[0].windspeedKmph' 2>/dev/null)
    humidity=$(echo "$data" | jq -r '.current_condition[0].humidity' 2>/dev/null)
    local code=$(echo "$data" | jq -r '.current_condition[0].weatherCode' 2>/dev/null)

    # Weather icon based on code
    case "$code" in
        113) icon="☀️" ;;
        116) icon="⛅" ;;
        119|122) icon="☁️" ;;
        176|180|263|266|293|296|299|302|305|308) icon="🌧️" ;;
        179|182|185|227|230|323|326|329|332|335|338|350|368|371|374|377) icon="❄️" ;;
        200|386|389|392|395) icon="⛈️" ;;
        248|260) icon="🌫️" ;;
        *) icon="🌡️" ;;
    esac

    echo "$icon|$temp|$feels|$desc|$wind|$humidity"
}

# --- Short format for waybar ---
short_format() {
    local data
    data=$(fetch_weather "$CITY")

    if [[ -z "$data" ]]; then
        echo '{"text": "? N/A", "tooltip": "Weather unavailable", "class": "error"}'
        return
    fi

    IFS='|' read -r icon temp feels desc wind humidity <<< "$(parse_weather "$data")"

    local tooltip="$CITY: $desc\nFeels like: ${feels}°C\nWind: ${wind}km/h\nHumidity: ${humidity}%"
    echo "{\"text\": \"$icon ${temp}°C\", \"tooltip\": \"$tooltip\", \"class\": \"weather\"}"
}

# --- Popup via rofi ---
popup_format() {
    local output=""

    for city in "$CITY" "$CITY2"; do
        local data
        data=$(fetch_weather "$city")

        if [[ -z "$data" ]]; then
            output+="$city: unavailable\n\n"
            continue
        fi

        IFS='|' read -r icon temp feels desc wind humidity <<< "$(parse_weather "$data")"

        # Forecast
        local forecast=""
        for i in 1 2; do
            local fdate fmax fmin fdesc
            fdate=$(echo "$data" | jq -r ".weather[$i].date" 2>/dev/null)
            fmax=$(echo "$data" | jq -r ".weather[$i].maxtempC" 2>/dev/null)
            fmin=$(echo "$data" | jq -r ".weather[$i].mintempC" 2>/dev/null)
            fdesc=$(echo "$data" | jq -r ".weather[$i].hourly[4].weatherDesc[0].value" 2>/dev/null)
            forecast+="  $fdate — $fmin°C / $fmax°C — $fdesc\n"
        done

        output+="$icon  $city — $desc\n"
        output+="  🌡️  Temp: ${temp}°C (feels ${feels}°C)\n"
        output+="  💨  Wind: ${wind} km/h\n"
        output+="  💧  Humidity: ${humidity}%\n"
        output+="  📅  Forecast:\n$forecast\n"
    done

    echo -e "$output" | wofi --dmenu \
        -p "Weather" \
        -no-custom \
        -theme-str 'window {width: 500px;} listview {lines: 20;}'
}

# --- Main ---
case "$1" in
    --short)  short_format ;;
    --popup)  popup_format ;;
    *)        short_format ;;
esac
