#!/usr/bin/env bash

DOTFILES="$HOME/.dotfiles"

while true; do
    package=$(
        find "$DOTFILES" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
        sort |
        rofi -dmenu -i -p "Dotfiles"
    )

    [ -z "$package" ] && exit 0

    file=$(
        {
            echo ".."
            find "$DOTFILES/$package" -type f |
                sed "s|$DOTFILES/$package/||" |
                sort
        } | rofi -dmenu -i -p "$package"
    )

    [ -z "$file" ] && exit 0
    [ "$file" = ".." ] && continue

    emacsclient -r -n "$DOTFILES/$package/$file"
    exit 0
done
