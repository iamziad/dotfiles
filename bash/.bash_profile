# .bash_profile

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export BASH_ENV="$HOME/.config/bash/rc"

export EDITOR=emacsclient
export TERMINAL=alacritty

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

if [ -z "$DISPLAY" ] && [ -f ~/.xinitrc ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
