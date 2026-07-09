#!/bin/bash

MY_MAIN_MONITOR="HDMI-1"

MONITOR_SECONDARY=$(xrandr | awk -v main="$MY_MAIN_MONITOR" '/ connected/ && $1 != main {print $1; exit}')

MAIN_CONNECTED=$(xrandr | grep "^$MY_MAIN_MONITOR connected")

if [ -n "$MAIN_CONNECTED" ] && [ -n "$MONITOR_SECONDARY" ]; then
    xrandr --output "$MY_MAIN_MONITOR" --primary --auto \
           --output "$MONITOR_SECONDARY" --auto --left-of "$MY_MAIN_MONITOR"

elif [ -n "$MAIN_CONNECTED" ]; then
    xrandr --output "$MY_MAIN_MONITOR" --primary --auto

else
    ANY_MONITOR=$(xrandr | awk '/ connected/ {print $1; exit}')
    if [ -n "$ANY_MONITOR" ]; then
        xrandr --output "$ANY_MONITOR" --primary --auto
    fi
fi
