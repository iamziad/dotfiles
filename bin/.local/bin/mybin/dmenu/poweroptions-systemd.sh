#!/usr/bin/env bash

options="Shutdown\nReboot\nSuspend\nHibernate\nLock\nLogout"
chosen=$(echo -e "$options" | dmenu -i -fn monospace:size=11 -p "Power Options:")

case "$chosen" in
    Shutdown) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
    Suspend) /home/ziad/.local/bin/i3/i3lock.sh && systemctl suspend ;;
    Hibernate) systemctl hibernate ;;
    Lock) /home/ziad/.local/bin/i3/i3lock.sh ;;
    Logout) i3-msg exit ;;
esac
