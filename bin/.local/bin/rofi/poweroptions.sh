#!/usr/bin/env bash

chosen=$(printf " Shutdown\n󰜉 Reboot\n󰤄 Suspend\n󰒲 Hibernate\n󰌾 Lock\n󰍃 Logout" \
    | rofi -dmenu -i -p "Power")

case "$chosen" in
    " Shutdown") loginctl poweroff ;;
    "󰜉 Reboot") loginctl reboot ;;
    "󰤄 Suspend") loginctl suspend ;;
    "󰒲 Hibernate") loginctl hibernate ;;
    "󰌾 Lock") loginctl lock-session ;;
    "󰍃 Logout") loginctl terminate-user "$USER" ;;
esac
