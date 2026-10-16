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
abbr -a gss 'git status --short'
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
    set -l last_status $status
    set -l last_duration $CMD_DURATION

    set_color b8bb26
    echo -n (whoami)
    set_color normal
    echo -n '@'
    set_color b8bb26
    echo -n $hostname
    set_color normal
    echo -n ' '

    set_color 83a598
    echo -n (prompt_pwd)
    set_color normal

    set -l branch (git branch --show-current 2>/dev/null)
    if test -n "$branch"
        set -l dirty ""
        if not git diff --quiet 2>/dev/null
            set dirty "*"
        else if not git diff --cached --quiet 2>/dev/null
            set dirty "*"
        end
        set_color fabd2f
        echo -n " ($branch$dirty)"
        set_color normal
    end

    if test "$last_duration" -gt 300; and test "$last_duration" -le 300000
        set_color 928374
        if test "$last_duration" -ge 1000
            printf " %.1fs" (math "$last_duration / 1000")
        else
            printf " %dms" $last_duration
        end
        set_color normal
    end

    if test $last_status -ne 0
        set_color fb4934
        echo -n " [$last_status]"
        set_color normal
    end

    if test $last_status -eq 0
        set_color b8bb26
    else
        set_color fb4934
    end
    echo -n ' $ '
    set_color normal
end

fnm env --use-on-cd | source
