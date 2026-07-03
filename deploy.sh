#!/bin/bash

# Hardware Specific Config
# - i3blocks
#  - CPU load
#  - CPU temp

PROFILE=$1

if ! command -v stow &> /dev/null; then
    echo "Error: 'stow' is not installed." >&2
    exit 1
fi


DESKTOP_GUI=(runit git alacritty vim tmux bash)
DESKTOP_I3=("${DESKTOP_GUI[@]}" bin i3 x11 redshift dunst picom mimeapps gtk)

if [ "$PROFILE" = "desktop-gui" ]; then
    echo "$0: deploying $1.."
    stow -v "${DESKTOP_GUI[@]}"
else
    echo "$0: deploying i3 profile.."

    mkdir -p \
	    "$HOME/.config" \
	    "$HOME/.local/share" \
	    "$HOME/.cache" \
	    "$HOME/.local/state"

    echo "$0: Created home skeleton"
    stow -v "${DESKTOP_I3[@]}"
fi

#echo -e "$0: deploying system.."
#sudo stow -v -t / system

echo -e "$0: done!"
