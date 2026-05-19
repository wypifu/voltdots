#!/usr/bin/env bash
# voltdots — snip.sh
# Screen snip — region selection, save to file and copy to clipboard

SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SAVE_DIR"

FILENAME="Screenshot_$(date '+%Y-%m-%d_%H.%M.%S').png"
FILEPATH="$SAVE_DIR/$FILENAME"

# Select region
REGION=$(slurp) || exit 1

# Capture
grim -g "$REGION" "$FILEPATH"

# Copy to clipboard
wl-copy < "$FILEPATH"

# Notify
notify-send "Screenshot saved" "$FILENAME" -i "$FILEPATH" -a "Screenshot"
