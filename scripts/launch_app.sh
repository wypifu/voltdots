#!/usr/bin/env bash
# voltdots — launch_app.sh
# Launch preferred app with fallback

CUSTOM="$HOME/.voltdots/hypr/custom/defaults.conf"
DEFAULT="$HOME/.voltdots/hypr/default/defaults.conf"

# Load both — custom overrides default
source "$DEFAULT"
[[ -f "$CUSTOM" ]] && source "$CUSTOM"

LAUNCH="$HOME/.voltdots/scripts/launch_first_available.sh"

case "$1" in
    terminal)   $LAUNCH $VOLTTERM $VOLTTERM_FALLBACK ;;
    filemanager) $LAUNCH $VOLTFILES $VOLTFILES_FALLBACK ;;
    browser)    $LAUNCH $VOLTBROWSER $VOLTBROWSER_FALLBACK ;;
    editor)     $LAUNCH $VOLTEDITOR $VOLTEDITOR_FALLBACK ;;
    video)      $LAUNCH $VOLTVIDEO $VOLTVIDEO_FALLBACK ;;
    images)     $LAUNCH $VOLTIMAGES $VOLTIMAGES_FALLBACK ;;
    pdf)        $LAUNCH $VOLTPDF $VOLTPDF_FALLBACK ;;
    *)          echo "launch_app: unknown app type: $1" >&2; exit 1 ;;
esac
