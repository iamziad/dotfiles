#!/bin/bash

#export XDG_SESSION_TYPE=x11
#export XDG_CURRENT_DESKTOP=i3
# export LIBVA_DRIVER_NAME=radeonsi

# Xresources
xrdb -merge "$HOME/.Xresources" || true

# Monitors
~/Scripts/screenlayout.sh || echo "screenlayout failed"

# Keyboard
setxkbmap -layout us,ara -variant ,digits -option grp:win_space_toggle -option ctrl:nocaps
xset r rate 300 50
xcape -e 'Caps_Lock=Escape'
pkill xcape
xcape &

# Daemons
/usr/libexec/polkit-gnome-authentication-agent-1 &
xsettingsd &
pipewire &
picom --backend glx \
      --no-fading-openclose \
      --fade-in-step=1 --fade-out-step=1 --fade-delta=0 &
dunst &
nm-applet --indicator &
redshift-gtk &
emacs --daemon &

exec dbus-run-session i3
