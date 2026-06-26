#!/bin/bash

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_DESKTOP=i3
export DESKTOP_SESSION=i3

xrdb -merge "$HOME/.Xresources" || true

~/scripts/screenlayout.sh || echo "screenlayout failed"

setxkbmap -layout us,ara -variant ,digits -option grp:win_space_toggle -option ctrl:nocaps
xset r rate 250 35 &

/usr/libexec/xfce-polkit &
pipewire &
xsettingsd &
emacs --daemon &

sleep 0.5

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    exec dbus-run-session i3
else
    exec i3
fi
