#!/usr/bin/env bash

set -euo pipefail

pgrep -x i3lock >/dev/null && exit 0

cleanup() {
    dunstctl set-paused false
}

trap cleanup EXIT

xkb-switch -s us
dunstctl set-paused true

(
    sleep 60
    pgrep -x i3lock >/dev/null && xset dpms force off
) &


LOCK_IMAGE="$HOME/Pictures/wallpapers/thumb-1920-1410361.jpg"

i3lock \
    -n \
    --image="$LOCK_IMAGE" \
    --tiling \
    --clock \
    --indicator \
    --show-failed-attempts \
    \
    --time-str="%H:%M:%S" \
    --date-str="%A, %d %B" \
    \
    --time-font="JetBrainsMono Nerd Font" \
    --date-font="JetBrainsMono Nerd Font" \
    --layout-font="JetBrainsMono Nerd Font" \
    --verif-font="JetBrainsMono Nerd Font" \
    --wrong-font="JetBrainsMono Nerd Font" \
    \
    --radius 95 \
    --ring-width 6 \
    \
    --ind-pos="x+150:y+h-150" \
    --time-pos="ix:iy-20" \
    --date-pos="ix:iy+20" \
    \
    --time-color=ffffffff \
    --date-color=ffffff88 \
    --ring-color=ffffff44 \
    --keyhl-color=00ff00ff \
    --wrong-color=ff0000ff

dunstctl set-paused false
