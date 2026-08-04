#!/bin/env bash

if [[ $EUID -ne 0 ]]; then
    echo "$0<Error>: Run this script with sudo." >&2
    exit 1
fi

USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

if [[ -z "$USER_HOME" ]]; then
    echo "$0<Error>: Cannot determine user home." >&2
    exit 1
fi

if ! command -v stow &> /dev/null; then
    echo "$0<Error>: 'stow' is not installed." >&2
    exit 1
fi

mkdir -p \
    "$USER_HOME/.config" \
    "$USER_HOME/.local/share" \
    "$USER_HOME/.local/bin" \
    "$USER_HOME/.local/state" \
    "$USER_HOME/.cache"

echo "$0<Log>: created XDG directories at $USER_HOME successfully."

sudo -u "$SUDO_USER" stow dev shell gui local editors

echo "$0<Log>: symlinked home config files successfully."

stow -t / nix

echo "$0<Log>: symlinked nixos config successfully."

echo "$0<Log>: done."
