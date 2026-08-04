export HISTFILE="$HOME/.local/state/bash/history"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# replaced by ly

#if [ -z "$DISPLAY" ] && [ -f "$XINITRC" ] && [ "$(tty)" = "/dev/tty1" ]; then
#    startx
#fi
