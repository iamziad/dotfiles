#!/usr/bin/env bash

LIGHT_THEME="Adwaita"
DARK_THEME="Adwaita-dark"
STATE_FILE="${XDG_RUNTIME_DIR:-$HOME/.cache}/gtk-theme-state"

GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
GTK4_SETTINGS="$HOME/.config/gtk-4.0/settings.ini"

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

for FILE in "$GTK3_SETTINGS" "$GTK4_SETTINGS"; do
    if [ ! -f "$FILE" ]; then
        printf '[Settings]\ngtk-theme-name=%s\ngtk-application-prefer-dark-theme=0\n' \
               "$LIGHT_THEME" > "$FILE"
    fi
done

CURRENT=$(grep "gtk-theme-name" "$GTK3_SETTINGS" | cut -d'=' -f2 | tr -d ' \r')

if [ "$CURRENT" = "$LIGHT_THEME" ]; then
    NEW_THEME="$DARK_THEME"
    DARK_VAL=1
    SCHEME="prefer-dark"
else
    NEW_THEME="$LIGHT_THEME"
    DARK_VAL=0
    SCHEME="prefer-light"
fi

sed -i \
    -e "s/gtk-theme-name=.*/gtk-theme-name=$NEW_THEME/" \
    -e "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=0/" \
    "$GTK3_SETTINGS" "$GTK4_SETTINGS"

XSETTINGSD_CONF="$HOME/.config/xsettingsd/xsettingsd.conf"
if [ -f "$XSETTINGSD_CONF" ]; then
    sed -i \
        -e "s|Net/ThemeName .*|Net/ThemeName \"$NEW_THEME\"|" \
        -e "s|Gtk/ApplicationPreferDarkTheme .*|Gtk/ApplicationPreferDarkTheme 0|" \
        "$XSETTINGSD_CONF"
    pkill -HUP xsettingsd 2>/dev/null
fi

if command -v gsettings &>/dev/null && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme    "$NEW_THEME" 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme "$SCHEME"    2>/dev/null
fi

echo "$NEW_THEME" > "$STATE_FILE"

pkill -RTMIN+10 i3blocks 2>/dev/null

echo "Switched to $NEW_THEME"
