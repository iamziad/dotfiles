#!/usr/bin/env bash

iface=$(ip route | awk '/default/ {print $5}' | head -n1)

if ip link show "$iface" | grep -q "state UP"; then
    speed=$(cat /sys/class/net/$iface/speed 2>/dev/null)

    path="/tmp/$(basename "$0")-${iface}"

    read rx < "/sys/class/net/${iface}/statistics/rx_bytes"
    read tx < "/sys/class/net/${iface}/statistics/tx_bytes"
    now=$(date +%s)

    if ! [[ -f "$path" ]]; then
        echo "${now} ${rx} ${tx}" > "$path"
        chmod 0666 "$path"
    fi

    read old < "$path"
    echo "${now} ${rx} ${tx}" > "$path"

    old=(${old//;/ })
    time_diff=$(( now - ${old[0]} ))

    if [[ "$time_diff" -gt 0 ]]; then
        rx_diff=$(( rx - old[1] ))
        tx_diff=$(( tx - old[2] ))
        rx_rate=$(( rx_diff / time_diff ))   # bytes/sec
        tx_rate=$(( tx_diff / time_diff ))   # bytes/sec

        rx_kib=$(( rx_rate >> 10 ))
        tx_kib=$(( tx_rate >> 10 ))

        if hash bc 2>/dev/null && [[ "$rx_rate" -gt 1048576 ]]; then
            rx_str="$(echo "scale=1; $rx_kib / 1024" | bc)M"
        else
            rx_str="${rx_kib}K"
        fi

        if hash bc 2>/dev/null && [[ "$tx_rate" -gt 1048576 ]]; then
            tx_str="$(echo "scale=1; $tx_kib / 1024" | bc)M"
        else
            tx_str="${tx_kib}K"
        fi
    else
        rx_str="0K"
        tx_str="0K"
    fi

    if [ -n "$speed" ]; then
        echo "E: ${rx_str} ${tx_str} (${speed}Mb/s)"
        echo "#00ff00"
        echo "#00ff00"
    else
        echo "E: ${rx_str} ${tx_str}"
        echo "#00ff00"
        echo "#00ff00"
    fi
else
    echo "E: down"
    echo "#ff0000"
    echo "#ff0000"
fi

# iface=$(ip route | awk '/default/ {print $5}' | head -n1)

# if ip link show "$iface" | grep -q "state UP"; then
#     ip_addr=$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
#     speed=$(cat /sys/class/net/$iface/speed 2>/dev/null)

#     if [ -n "$speed" ]; then
#         echo "E: $ip_addr (${speed}Mb/s)"
#         echo "#00ff00"
#         echo "#00ff00"
#     else
#         echo "E: $ip_addr"
#         echo "#00ff00"
#         echo "#00ff00"
#     fi
# else
#     echo "E: down"
#     echo "#ff0000"
#     echo "#ff0000"
# fi
