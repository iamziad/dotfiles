#!/bin/bash

PROFILE=$1

DESKTOP_GUI=(git alacritty vim tmux bash)
DESKTOP_I3=("${DESKTOP_GUI[@]}" i3 redshift dunst xorg Scripts)

if [ "$PROFILE" = "desktop-gui" ]; then
    echo "$0: deploying $1.."
    stow -v "${DESKTOP_GUI[@]}"

    echo -e "$0: deploying system.."
    sudo stow -v -t / system

else
    echo "$0: deploying i3 profile.."
    stow -v "${DESKTOP_I3[@]}"

    echo -e "$0: deploying system.."
    sudo stow -v -t / system
fi

echo -e "$0: done!"
