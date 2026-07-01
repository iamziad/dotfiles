# .bash_profile

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XAUTHORITY=$XDG_RUNTIME_DIR/Xauthority

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

if [ -z "$DISPLAY" ] && [ -f "$XDG_CONFIG_HOME/x11/xinitrc" ] && [ "$(tty)" = "/dev/tty1" ]; then
    startx "$XDG_CONFIG_HOME/x11/xinitrc" --
fi
