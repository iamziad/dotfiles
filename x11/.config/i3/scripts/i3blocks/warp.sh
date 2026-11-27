#!/usr/bin/env bash

toggle_warp() {
    if warp-cli status 2>/dev/null | grep -q "Connected"; then
        warp-cli disconnect >/dev/null 2>&1
    else
        warp-cli connect >/dev/null 2>&1

        for i in {1..10}; do
            if warp-cli status 2>/dev/null | grep -q "Connected"; then
                break
            fi
            sleep 1
        done
    fi

    pkill -RTMIN+10 i3blocks
}

case "$BLOCK_BUTTON" in
    1|3)
        toggle_warp
        ;;
esac

if warp-cli status 2>/dev/null | grep -q "Connected"; then
    echo "WARP: on"
    echo "WARP: on"
    echo "#00ff00"
else
    echo "WARP: off"
    echo "WARP: off"
    echo "#ff0000"
fi
