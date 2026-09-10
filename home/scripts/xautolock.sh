#!/bin/bash
xautolock -time 15 \
    -locker "systemctl suspend" \
    -notify 30 \
    -notifier "my-suspend-notify"
