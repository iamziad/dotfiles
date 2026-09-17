# Translated from home/shell/fish.nix + home/shell/aliases.nix.
# Dropped on purpose (no Nix on this machine): nix_shell_indicator,
# the `nrs` (nixos-rebuild) and `hms` (home-manager switch) abbrs.

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

# --- functions ---
function prompt_is_dark_mode
    set -l settings "$HOME/.config/gtk-3.0/settings.ini"
    set -l line (grep "gtk-theme-name" "$settings" 2>/dev/null)
    test -z "$line"; and return 0
    string match -q "*-dark*" -- "$line"
end

function get_trimmed_pwd
    set -l current_pwd (string replace -r "^$HOME" "~" -- $PWD)

    if test "$current_pwd" = /
        echo /
        return
    end

    set -l parts (string split "/" -- $current_pwd)
    set -l n (count $parts)

    if test $n -gt 2
        echo "$parts[-2]/$parts[-1]"
    else
        echo $current_pwd
    end
end

function git_branch
    set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$branch"
        set branch (git rev-parse --short HEAD 2>/dev/null)
    end
    if test -n "$branch"
        echo " $branch"
    end
end

function fish_prompt
    if prompt_is_dark_mode
        set_color fb4934
        echo -n "["
        set_color fabd2f
        echo -n (whoami)
        set_color b8bb26
        echo -n "@"
        set_color 83a598
        echo -n (prompt_hostname)
        set_color normal
        echo -n " "
        set_color b8bb26
        echo -n (get_trimmed_pwd)
        set_color d3869b
        echo -n (git_branch)
        set_color fb4934
        echo -n "]"
        set_color normal
        echo -n "\$ "
    else
        set_color 9d0006
        echo -n "["
        set_color 9d5000
        echo -n (whoami)
        set_color 5c600a
        echo -n "@"
        set_color 044d5a
        echo -n (prompt_hostname)
        set_color normal
        echo -n " "
        set_color 5c600a
        echo -n (get_trimmed_pwd)
        set_color 6a2c53
        echo -n (git_branch)
        set_color 9d0006
        echo -n "]"
        set_color normal
        echo -n "\$ "
    end
end

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
fnm env --use-on-cd | source
