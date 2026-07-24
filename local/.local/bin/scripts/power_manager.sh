#!/usr/bin/env bash

xset dpms 300 480 1080
xset +dpms

lock="~/.local/bin/i3/i3lock.sh"
xss-lock --transfer-sleep-lock -- eval "$lock" &

while true; do
    DPMS_STATUS=$(xset q | grep "Monitor is" | awk '{print $3}')

    if [ "$DPMS_STATUS" = "Off" ]; then
        if pgrep -x i3lock >/dev/null; then
            systemctl suspend
        fi
    fi
    sleep 30
done
