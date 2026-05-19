#!/usr/bin/env bash
# voltdots — record.sh
# Screen recorder — toggle start/stop
# Uses gpu-screen-recorder (AMD/Nvidia) with fallback to wf-recorder

SAVE_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"
mkdir -p "$SAVE_DIR"

FILENAME="recording_$(date '+%Y-%m-%d_%H.%M.%S').mp4"
FILEPATH="$SAVE_DIR/$FILENAME"

# --- Stop if already recording ---
if pgrep -f gpu-screen-recorder > /dev/null; then
    pkill -f gpu-screen-recorder
    notify-send "Recording stopped" "$FILENAME" -a "Recorder"
    exit 0
fi

if pgrep -f wf-recorder > /dev/null; then
    pkill -f wf-recorder
    notify-send "Recording stopped" "$FILENAME" -a "Recorder"
    exit 0
fi

# --- Select region ---
REGION=$(slurp -f '%wx%h+%x+%y') || exit 1

# --- Start recording ---
# Try gpu-screen-recorder first (better AMD/Nvidia support)
if command -v gpu-screen-recorder > /dev/null; then
    notify-send "Recording started" "$FILENAME" -a "Recorder"
    gpu-screen-recorder -w region -region "$REGION" -f 60 -o "$FILEPATH"
    exit 0
fi

# Fallback to wf-recorder
if command -v wf-recorder > /dev/null; then
    notify-send "Recording started" "$FILENAME" -a "Recorder"
    wf-recorder -f "$FILEPATH" -g "$(slurp)" &
    exit 0
fi

notify-send "Recording failed" "No recorder found (install gpu-screen-recorder or wf-recorder)" -a "Recorder"
exit 1
