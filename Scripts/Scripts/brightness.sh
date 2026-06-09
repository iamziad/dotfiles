#!/bin/bash
# brightness.sh <name> <+/->

set -euo pipefail

NAME=$1
SIGN=$2
CACHE_FILE="/tmp/ddc_bus_${NAME}.txt"

# ── resolve bus ───────────────────────────────────────────────
get_bus() {
    ddcutil detect 2>/dev/null | awk -v name="$NAME" '
        /^Display/ { found=0; bus="" }
        /I2C bus:/  { match($0, /[0-9]+$/); bus=substr($0, RSTART, RLENGTH) }
        $0 ~ name   { found=1 }
        /VCP version|DDC communication/ { if (found && bus != "") { print bus; exit } }
    '
}

if [[ ! -f "$CACHE_FILE" ]]; then
    notify-send "DDCutil" "Detecting bus for $NAME…"
    BUS_NUM=$(get_bus)
    if [[ -z "$BUS_NUM" ]]; then
        notify-send "Error" "Couldn't find display: $NAME"
        exit 1
    fi
    echo "$BUS_NUM" > "$CACHE_FILE"
fi

BUS=$(cat "$CACHE_FILE")

# ── get current brightness ────────────────────────────────────
get_value() {
    ddcutil --bus "$BUS" getvcp 10 --sleep-multiplier 0.05 2>/dev/null \
        | grep -oP 'current value =\s*\K[0-9]+'
}

CURRENT=$(get_value)
if [[ -z "$CURRENT" ]]; then
    # Cache might be stale — try re-detecting once
    rm -f "$CACHE_FILE"
    BUS_NUM=$(get_bus)
    if [[ -z "$BUS_NUM" ]]; then
        notify-send "Error" "Lost connection to $NAME"
        exit 1
    fi
    echo "$BUS_NUM" > "$CACHE_FILE"
    BUS=$BUS_NUM
    CURRENT=$(get_value)
fi

# ── calculate new value ───────────────────────────────────────
case "$SIGN" in
    +) NEW=$(( CURRENT + 10 )) ;;
    -) NEW=$(( CURRENT - 10 )) ;;
    *) NEW=$SIGN ;;           # absolute value passed directly
esac

# clamp 0–100
NEW=$(( NEW < 0   ? 0   : NEW ))
NEW=$(( NEW > 100 ? 100 : NEW ))

# ── set & notify ──────────────────────────────────────────────
NOTIFY_ID_FILE="/tmp/ddc_notify_${NAME}.txt"

if [[ -f "$NOTIFY_ID_FILE" ]]; then
    NOTIFY_ARGS="-r $(cat "$NOTIFY_ID_FILE")"
else
    NOTIFY_ARGS=""
fi

ddcutil --bus "$BUS" --noverify --sleep-multiplier 0.05 setvcp 10 "$NEW"

NEW_ID=$(notify-send -p $NOTIFY_ARGS -h "int:value:$NEW" "$NAME — Brightness" "${NEW}%")
echo "$NEW_ID" > "$NOTIFY_ID_FILE"
