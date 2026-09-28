#!/bin/bash
for i in $(seq 30 -1 1); do
    notify-send -r 9999 -t 1100 "Suspend Alert" "Suspend in $i seconds..."
    sleep 1
done
