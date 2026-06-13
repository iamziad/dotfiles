# To be sourced in .bash_profile

[[ -f ~/.xinitrc && -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
