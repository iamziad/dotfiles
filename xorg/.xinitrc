#!/bin/bash

export XDG_SESSION_TYPE=x11

# Xresources
xrdb -merge "$HOME/.Xresources"

# Monitors
~/Scripts/screenlayout.sh

# Keyboard
setxkbmap -layout us,ara -variant ,digits -option grp:win_space_toggle
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
emacs --daemon &

exec i3
