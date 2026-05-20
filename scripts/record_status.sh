#!/usr/bin/env bash
# voltdots — record_status.sh
# Returns recording status for waybar custom/record module

if pgrep -f gpu-screen-recorder > /dev/null || pgrep -f wf-recorder > /dev/null; then
    echo '{"text": " ", "tooltip": "Recording — click to stop", "class": "recording"}'
else
    echo '{"text": " ", "tooltip": "Record screen (Super+Shift+R)", "class": ""}'
fi
