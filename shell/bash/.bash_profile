export HISTFILE="$HOME/.local/state/bash/history"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority
export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
export XDEB_PKGROOT=${HOME}/.config/xdeb

export BROWSER=firefox
export EDITOR=/usr/bin/emacs
export TERM=alacritty

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

if [ -z "$DISPLAY" ] && [ -f "$XINITRC" ] && [ "$(tty)" = "/dev/tty1" ]; then
    startx
fi
