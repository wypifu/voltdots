#!/usr/bin/env bash
# voltdots — launch_app.sh
# Launch preferred app with fallback
# Usage: launch_app.sh terminal|filemanager|browser|editor|video|images|pdf

# Load machine defaults if available, fallback to system defaults
CUSTOM="$HOME/.voltdots/hypr/custom/defaults.conf"
DEFAULT="$HOME/.voltdots/hypr/default/defaults.conf"

[[ -f "$CUSTOM" ]] && source "$CUSTOM" || source "$DEFAULT"

case "$1" in
    terminal)
        ~/.voltdots/scripts/launch_first_available.sh "$VOLTTERM" $VOLTTERM_FALLBACK
        ;;
    filemanager)
        ~/.voltdots/scripts/launch_first_available.sh "$VOLTFILES" $VOLTFILES_FALLBACK
        ;;
    browser)
        ~/.voltdots/scripts/launch_first_available.sh "$VOLTBROWSER" $VOLTBROWSER_FALLBACK
        ;;
    editor)
        ~/.voltdots/scripts/launch_first_available.sh "$VOLTEDITOR" $VOLTEDITOR_FALLBACK
        ;;
    video)
        ~/.voltdots/scripts/launch_first_available.sh "$VOLTVIDEO" $VOLTVIDEO_FALLBACK
        ;;
    images)
        ~/.voltdots/scripts/launch_first_available.sh "$VOLTIMAGES" $VOLTIMAGES_FALLBACK
        ;;
    pdf)
        ~/.voltdots/scripts/launch_first_available.sh "$VOLTPDF" $VOLTPDF_FALLBACK
        ;;
    *)
        echo "launch_app: unknown app type: $1" >&2
        exit 1
        ;;
esac
