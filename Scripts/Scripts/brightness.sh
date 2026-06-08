#!/bin/bash
# brightness.sh <bus> <name> <+/- amount>
BUS=$1
NAME=$2
CHANGE=$3

ddcutil --bus "$BUS" --noverify --sleep-multiplier 0.05 setvcp 10 "$CHANGE" 10
VALUE=$(ddcutil --bus "$BUS" getvcp 10 --sleep-multiplier 0.05 | grep -oP 'current value =\s*\K[0-9]+')
notify-send -h "int:value:$VALUE" "$NAME — Brightness" "${VALUE}%"
