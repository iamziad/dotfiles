#!/usr/bin/env bash

options="Shutdown\nReboot\nSuspend\nHibernate\nLock\nLogout"

chosen=$(echo -e "$options" | dmenu -i -p "Power Options:")

case "$chosen" in
    Shutdown)  systemctl poweroff ;;
    Reboot)    systemctl reboot ;;
    Suspend)   systemctl suspend ;;
    Hibernate) systemctl hibernate ;;
    Lock)      loginctl lock-session ;;
    Logout)    loginctl terminate-user "$USER" ;;
esac
