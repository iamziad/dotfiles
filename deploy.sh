#!/bin/bash

# Hardware Specific Config
# - i3blocks
#  - CPU load
#  - CPU temp

if ! command -v stow &> /dev/null; then
    echo "Error: 'stow' is not installed." >&2
    exit 1
fi

mkdir -p \
	"$HOME/.config" \
	"$HOME/.local/share" \
	"$HOME/.local/bin" \
	"$HOME/.local/state" \
	"$HOME/.cache"

echo "$0: Created home skeleton"

