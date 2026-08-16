set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_CACHE_HOME "$HOME/.cache"

if status is-interactive
    set -g fish_greeting ""

    # Safe / Behavior-altering Aliases
    alias ls "ls --color=auto"
    alias grep "grep --color"
    alias rm "rm -i"
    alias mvn "mvn -gs $XDG_CONFIG_HOME/maven/settings.xml"

    # Quick Expandable Abbreviations
    abbr -a c "xclip -selection clipboard"
    abbr -a nrs "sudo nixos-rebuild switch"

    # Git
    abbr -a gs "git status"
    abbr -a ga "git add"
    abbr -a gc "git commit"
    abbr -a gl "git log"
    abbr -a gd "git diff"

    # Tmux
    abbr -a tl "tmux list-sessions"
    abbr -a ta "tmux attach-session -t"
    abbr -a tn "tmux new-session -s"
    abbr -a tk "tmux kill-session -t"

    # Emacs
    abbr -a ecf "emacsclient -c"
    abbr -a ect "emacsclient -t"
    abbr -a et "emacs -nw"
    abbr -a ed "ect ."
    abbr -a emacs-kill "emacsclient -e '(kill-emacs)'"
    abbr -a emacs-start "emacs --daemon"
    abbr -a emacs-reload "emacsclient -e '(kill-emacs)' 2>/dev/null; sleep 0.3; emacs --daemon"
end
