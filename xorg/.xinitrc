#!/bin/bash

# Xresources
xrdb -merge "$HOME/.Xresources"

# Monitors
MONITOR_PRIMARY=$(xrandr | awk '/ connected/ {print $1; exit}')
MONITOR_SECONDARY=$(xrandr | awk '/ connected/ {found++; if(found==2) {print $1; exit}}')
if [ -n "$MONITOR_SECONDARY" ]; then
    xrandr --output "$MONITOR_PRIMARY" --right-of "$MONITOR_SECONDARY"
fi

# Keyboard
setxkbmap -layout us,ara -variant ,digits -option grp:win_space_toggle,caps:ctrl_modifier
xset r rate 300 50

# Daemons
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
xsettingsd &
picom --backend glx \
      --no-fading-openclose \
      --fade-in-step=1 --fade-out-step=1 --fade-delta=0 &
dunst &
nm-applet --indicator &
redshift-gtk &
flameshot &
emacs --daemon &

exec i3
