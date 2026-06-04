# XDB
[[ -f ~/.Xresources ]] && xrdb merge ~/.Xresources

# XDG
[ -f ~/.dbus.sh ] && bash ~/.dbus.sh

# Monitors
MONITOR_PRIMARY=$(xrandr | awk '/ connected/ {print $1; exit}')
MONITOR_SECONDARY=$(xrandr | awk '/ connected/ {found++; if(found==2) {print $1; exit}}')

if [ -n "$MONITOR_SECONDARY" ]; then
    xrandr --output "$MONITOR_PRIMARY" --right-of "$MONITOR_SECONDARY"
fi

# Keyboard Layout
setxkbmap -layout us,ara -variant ,digits -option grp:win_space_toggle,caps:ctrl_modifier

# Wallpaper
feh --bg-scale --no-fehbg "$(find ~/Wallpapers/ -maxdepth 1 -type f | shuf -n 1)"

# Daemons
pkill picom; pkill dunst
picom --backend glx -b &
dunst &

# Apps
gromit-mpx &
nm-applet &
redshift-gtk &

# Lock
xidlehook \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 600 "$HOME/dotfiles/i3/.config/i3/scripts/i3lock.sh" "" \
  --timer 1200 "systemctl suspend" "" &

exec "${1:-i3}"
