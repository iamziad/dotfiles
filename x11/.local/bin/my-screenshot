#!/usr/bin/env bash
# $1 = "full" | "select"
# $2 = "clip"  | "save"

SAVE_DIR="$HOME/Pictures/screenshots"
TMP="/tmp/screenshot_$(date +%s).png"

mkdir -p "$SAVE_DIR"

# Capture
if [[ "$1" == "select" ]]; then
    maim -s "$TMP" || exit 1
else
    maim "$TMP" || exit 1
fi

# Destination
if [[ "$2" == "save" ]]; then
    DEST="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
    cp "$TMP" "$DEST"
    MSG="Saved to Pictures"
else
    xclip -selection clipboard -t image/png < "$TMP"
    MSG="Copied to clipboard"
fi

# Notification with thumbnail
dunstify \
    -a "screenshot" \
    -i "$TMP" \
    -h "string:image-path:$TMP" \
    -t 3000 \
    "Screenshot" "$MSG"
