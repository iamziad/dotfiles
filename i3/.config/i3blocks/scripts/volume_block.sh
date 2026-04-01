#!/bin/bash

case "$BLOCK_BUTTON" in
    1) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    4) wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    5) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
esac

status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
# awk needs standard single quotes here since we aren't wrapping it in sh -c anymore
vol=$(echo "$status" | awk '{print int($2*100)}')

if echo "$status" | grep -q MUTED; then
    echo "󰝟 Mute"
elif [ "$vol" -lt 45 ]; then
    echo " $vol%"
else
    echo " $vol%"
fi
