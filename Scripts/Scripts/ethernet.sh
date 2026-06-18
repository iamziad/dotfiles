#!/usr/bin/env bash

iface=$(ip route | awk '/default/ {print $5; exit}')

if [[ -z "$iface" ]]; then
    echo "󰌙"
    echo "󰌙"
    echo "#fb4934"
    exit 0
fi

if [[ "$iface" == e* ]]; then
    echo "󰈀"
    echo "󰈀"
    echo "#b8bb26"
else
    echo "󰌙"
    echo "󰌙"
    echo "#928374"
fi
