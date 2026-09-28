#!/usr/bin/env bash
#
# my-dim-inactive.sh — per-monitor idle dimmer for i3/X11 (real hardware
# dimming via DDC/CI, using ddcutil)
#
# Watches which output (monitor) the mouse cursor is currently over,
# using xrandr geometry. Any OTHER monitor that hasn't had the mouse
# on it for $THRESHOLD seconds gets its real hardware brightness
# lowered via `ddcutil setvcp 10 <level> --display <N>` (VCP feature
# 0x10 = Brightness, actual backlight — not a gamma trick). Right
# before dimming, it reads the monitor's CURRENT brightness and
# remembers it, so when the mouse comes back it restores that exact
# value — not a fixed "100" — in case you'd manually set it lower.
#
# Only monitors you explicitly map on the command line are touched.
# Anything you don't map (e.g. a laptop panel with no DDC/CI support)
# is left completely alone.
#
# Deps: xrandr, xdotool, ddcutil
#
# Usage:
#   ./my-dim-inactive.sh XRANDR_NAME:DDC_DISPLAY_NUM [XRANDR_NAME:DDC_DISPLAY_NUM ...]
#
# Find the xrandr names with `xrandr --query` and the ddcutil display
# numbers with `ddcutil detect`. Example:
#   ./my-dim-inactive.sh HDMI-1:1 DP-1:2
#
# Config via env vars:
#   THRESHOLD=90 DIM_LEVEL=10 NORMAL_LEVEL=100 ./my-dim-inactive.sh HDMI-1:1 DP-1:2
#
# If a monitor errors out on setvcp verification (some models do),
# add --noverify (already the default here) or tweak DDCUTIL_OPTS,
# e.g. DDCUTIL_OPTS="--noverify --sleep-multiplier 2"

set -uo pipefail

THRESHOLD="${THRESHOLD:-120}"                 # seconds without the mouse before a monitor dims
DIM_LEVEL="${DIM_LEVEL:-0}"                 # hardware brightness while dimmed (0-100)
NORMAL_LEVEL="${NORMAL_LEVEL:-100}"          # fallback restore value, only used if reading
                                              # the monitor's current brightness fails
POLL_INTERVAL="${POLL_INTERVAL:-1}"          # seconds between checks
DDCUTIL_OPTS="${DDCUTIL_OPTS:---noverify}"   # extra ddcutil flags

command -v xrandr  >/dev/null 2>&1 || { echo "xrandr not found" >&2; exit 1; }
command -v xdotool  >/dev/null 2>&1 || { echo "xdotool not found — install it first" >&2; exit 1; }
command -v ddcutil  >/dev/null 2>&1 || { echo "ddcutil not found — install it first" >&2; exit 1; }

if (( $# == 0 )); then
    echo "Usage: $0 XRANDR_NAME:DDC_DISPLAY_NUM [XRANDR_NAME:DDC_DISPLAY_NUM ...]" >&2
    echo "  xrandr names:        xrandr --query" >&2
    echo "  ddcutil display nums: ddcutil detect" >&2
    exit 1
fi

declare -A ddc_map=()
for arg in "$@"; do
    if [[ "$arg" != *:* ]]; then
        echo "Bad argument: '$arg' (expected XRANDR_NAME:DDC_DISPLAY_NUM)" >&2
        exit 1
    fi
    name=${arg%%:*}
    num=${arg#*:}
    if [[ -z "$name" || ! "$num" =~ ^[0-9]+$ ]]; then
        echo "Bad argument: '$arg' (expected XRANDR_NAME:DDC_DISPLAY_NUM, e.g. HDMI-1:1)" >&2
        exit 1
    fi
    ddc_map[$name]=$num
done

declare -A last_seen=()
declare -A dimmed=()
declare -A saved_level=()   # brightness to restore to, captured right before each dim

set_brightness() {
    local name=$1 level=$2
    ddcutil --display "${ddc_map[$name]}" setvcp 10 "$level" $DDCUTIL_OPTS >/dev/null 2>&1
}

get_brightness() {
    local name=$1
    ddcutil --display "${ddc_map[$name]}" --brief getvcp 10 2>/dev/null | awk '{print $4}'
}

restore_all() {
    for name in "${!dimmed[@]}"; do
        [[ "${dimmed[$name]}" == "1" ]] && set_brightness "$name" "${saved_level[$name]:-$NORMAL_LEVEL}"
    done
    exit 0
}
trap restore_all SIGINT SIGTERM

# Prints "name width height x y" for every connected+active output
get_monitors() {
    xrandr --query | grep ' connected' | while read -r line; do
        name=$(awk '{print $1}' <<<"$line")
        geom=$(grep -oP '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+' <<<"$line" | head -n1)
        [[ -z "$geom" ]] && continue
        w=${geom%%x*}; rest=${geom#*x}
        h=${rest%%+*};  rest=${rest#*+}
        x=${rest%%+*};  y=${rest#*+}
        echo "$name $w $h $x $y"
    done
}

while true; do
    now=$(date +%s)
    monitors=$(get_monitors)

    mouse_loc=$(xdotool getmouselocation --shell 2>/dev/null)
    mx=$(grep -oP '(?<=^X=)-?[0-9]+' <<<"$mouse_loc")
    my=$(grep -oP '(?<=^Y=)-?[0-9]+' <<<"$mouse_loc")
    mx=${mx:-0}; my=${my:-0}

    # pass 1: figure out which mapped monitor the mouse is on right now
    active=""
    while read -r name w h x y; do
        [[ -z "${name:-}" ]] && continue
        [[ -z "${ddc_map[$name]+_}" ]] && continue   # not mapped -> ignore entirely

        if [[ -z "${last_seen[$name]+_}" ]]; then
            last_seen[$name]=$now
            dimmed[$name]=0
        fi
        if (( mx >= x && mx < x + w && my >= y && my < y + h )); then
            active=$name
        fi
    done <<<"$monitors"

    [[ -n "$active" ]] && last_seen[$active]=$now

    # pass 2: dim/undim mapped monitors based on elapsed idle time
    while read -r name w h x y; do
        [[ -z "${name:-}" ]] && continue
        [[ -z "${ddc_map[$name]+_}" ]] && continue

        elapsed=$(( now - last_seen[$name] ))
        if (( elapsed >= THRESHOLD )) && [[ "${dimmed[$name]}" == "0" ]]; then
            current=$(get_brightness "$name")
            [[ "$current" =~ ^[0-9]+$ ]] || current=$NORMAL_LEVEL
            saved_level[$name]=$current
            set_brightness "$name" "$DIM_LEVEL"
            dimmed[$name]=1
        elif (( elapsed < THRESHOLD )) && [[ "${dimmed[$name]}" == "1" ]]; then
            set_brightness "$name" "${saved_level[$name]:-$NORMAL_LEVEL}"
            dimmed[$name]=0
        fi
    done <<<"$monitors"

    sleep "$POLL_INTERVAL"
done
