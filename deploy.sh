#!/usr/bin/env bash
# Symlink every stow package into $HOME.
# Usage: ./deploy.sh [package...]   (no args = all packages)
# Run from the repo root as your normal user (no sudo).

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v stow &>/dev/null; then
    echo "$0<Error>: 'stow' is not installed." >&2
    exit 1
fi

PACKAGES=(emacs vim clang-format fish tmux git i3 picom dunst redshift xsettingsd xorg alacritty mimeapps applications gtk scripts)
[[ $# -gt 0 ]] && PACKAGES=("$@")

# Create real directories first so stow links files, not whole dirs
# (emacs, tmux, etc. write runtime files into their config dirs).
mkdir -p "$HOME/.config" "$HOME/.local/share" "$HOME/.local/bin" \
         "$HOME/.local/state" "$HOME/.cache"

stow --no-folding --restow --target="$HOME" "${PACKAGES[@]}"
echo "$0<Log>: stowed: ${PACKAGES[*]}"
