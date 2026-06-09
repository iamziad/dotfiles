#!/bin/bash

# Xresources
userresources=$HOME/.Xresources
xrdb -merge "$userresources"

# Polkit
lxpolkit &

# GTK settings
xsettingsd &

# Monitors
MONITOR_PRIMARY=$(xrandr | awk '/ connected/ {print $1; exit}')
MONITOR_SECONDARY=$(xrandr | awk '/ connected/ {found++; if(found==2) {print $1; exit}}')
if [ -n "$MONITOR_SECONDARY" ]; then
    xrandr --output "$MONITOR_PRIMARY" --right-of "$MONITOR_SECONDARY"
fi

# Keyboard
setxkbmap -layout us,ara -variant ,digits -option grp:win_space_toggle,caps:ctrl_modifier

exec i3
