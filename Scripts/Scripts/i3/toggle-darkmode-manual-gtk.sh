#!/bin/bash

# Define your preferred themes
LIGHT_THEME="Adwaita"
DARK_THEME="Adwaita-dark"

# Create config directories if they don't exist
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"

# Initialize files if they don't exist
for version in "3.0" "4.0"; do
    FILE="$HOME/.config/gtk-$version/settings.ini"
    if [ ! -f "$FILE" ]; then
        echo -e "[Settings]\ngtk-theme-name=$LIGHT_THEME\ngtk-application-prefer-dark-theme=0" > "$FILE"
    fi
done

# Now safely get the current theme
CURRENT_THEME=$(grep "gtk-theme-name" "$HOME/.config/gtk-3.0/settings.ini" | cut -d'=' -f2 | tr -d ' ')

if [ "$CURRENT_THEME" = "$LIGHT_THEME" ]; then
    NEW_THEME=$DARK_THEME
    VAL=1
    SCHEME="prefer-dark"
else
    NEW_THEME=$LIGHT_THEME
    VAL=0
    SCHEME="prefer-light"
fi

# Update the files
sed -i "s/gtk-theme-name=.*/gtk-theme-name=$NEW_THEME/" "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
sed -i "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$VAL/" "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

# Live update via gsettings
gsettings set org.gnome.desktop.interface gtk-theme "$NEW_THEME"
gsettings set org.gnome.desktop.interface color-scheme "$SCHEME"

echo "Success: Switched to $NEW_THEME"
