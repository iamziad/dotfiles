set -g fish_greeting ""

set -gx JAVA_HOME /usr/lib/jvm/java-25-openjdk
fish_add_path $JAVA_HOME/bin
fish_add_path ~/.local/bin
fish_add_path node_modules/.bin

# --- aliases ---
alias ls 'ls --color=auto'
alias grep 'grep --color'
alias rm 'rm -i'
alias mvn 'mvn -gs $XDG_CONFIG_HOME/maven/settings.xml'

# --- abbreviations ---
abbr -a c 'xclip -selection clipboard'

abbr -a gs 'git status'
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gl 'git log'
abbr -a gd 'git diff'

abbr -a tl 'tmux list-sessions'
abbr -a ta 'tmux attach-session -t'
abbr -a tn 'tmux new-session -s'
abbr -a tk 'tmux kill-session -t'

abbr -a ecf 'emacsclient -c'
abbr -a ect 'emacsclient -t'
abbr -a et 'emacs -nw'
abbr -a ed 'ect .'

abbr -a emacs-kill "emacsclient -e '(kill-emacs)'"
abbr -a emacs-start 'emacs --daemon'
abbr -a emacs-reload "emacsclient -e '(kill-emacs)' 2>/dev/null; sleep 0.3; emacs --daemon"

# --- session variables (from home.nix home.sessionVariables) ---
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATE_HOME "$HOME/.local/state"

set -gx EDITOR emacsclient
set -gx TERMINAL alacritty

if status is-interactive
    # direnv hook fish | source
end

function fish_prompt
    echo (set_color grey)(date +%H:%M) (set_color 87d7af)(prompt_pwd) (set_color ffafff)(fish_git_prompt) (set_color ffafff)'| '
end

fnm env --use-on-cd | source
