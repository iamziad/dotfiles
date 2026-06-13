# some more ls aliases
# alias ll='ls -l'
# alias la='ls -A'
# alias l='ls -CF'

# tmux
alias tl="tmux list-sessions"
alias ta="tmux attach-session -t"
alias tn="tmux new-session -s"
alias tk="tmux kill-session -t"

# emacs
alias ecf="emacsclient -c"
alias ect="emacsclient -t"
alias et="emacs -nw"
alias ed="ect ."
alias emacs-kill='emacsclient -e "(kill-emacs)"'
alias emacs-start="emacs --daemon"

function ecw() {
    emacsclient -e "(find-file-other-window \"$1\")"
}
