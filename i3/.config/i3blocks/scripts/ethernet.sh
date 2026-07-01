#!/usr/bin/env bash

iface=$(ip route | awk '/default/ {print $5}' | head -n1)

if ip link show "$iface" | grep -q "state UP"; then
    ip_addr=$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
    speed=$(cat /sys/class/net/$iface/speed 2>/dev/null)

    if [ -n "$speed" ]; then
        echo "E: $ip_addr (${speed}Mb/s)"
        echo "#00ff00"
        echo "#00ff00"
    else
        echo "E: $ip_addr"
        echo "#00ff00"
        echo "#00ff00"
    fi
else
    echo "E: down"
    echo "#ff0000"
    echo "#ff0000"
fi
