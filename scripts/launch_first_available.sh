#!/usr/bin/env bash
# voltdots — launch_first_available.sh
# Launch the first available app from a list
# Usage: launch_first_available.sh "app1" "app2" "app3"

for cmd in "$@"; do
    [[ -z "$cmd" ]] && continue
    command -v "${cmd%% *}" >/dev/null 2>&1 || continue
    eval "$cmd" &
    exit 0
done

echo "launch_first_available: no app found in list: $*" >&2
exit 1
