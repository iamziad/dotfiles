#!/usr/bin/env bash

iface=$(ip -6 route get 2606:4700:4700::1111 2>/dev/null \
    | awk '/dev/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')

if curl -6 --max-time 3 -s https://cloudflare.com/cdn-cgi/trace | grep -q "^ip="; then
    echo "IPv6: $iface"
    echo "IPv6: $iface"
    echo "#00ff00"
else
    echo "no IPv6"
    echo "no IPv6"
    echo "#ff0000"
fi
