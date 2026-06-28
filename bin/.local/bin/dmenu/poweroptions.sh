#!/usr/bin/env bash

options="Shutdown\nReboot\nSuspend\nHibernate\nLock\nLogout"

chosen=$(echo -e "$options" | dmenu -i -l 6 -p "Power Options:")

case "$chosen" in
    Shutdown)          loginctl poweroff ;;
    Reboot)            loginctl reboot ;;
    Suspend)           loginctl suspend ;;
    Hibernate)         loginctl hibernate ;;
    Lock)              loginctl lock-session ;;
    Logout)            loginctl terminate-user "$USER" ;;
esac
