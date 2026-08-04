# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color'

# Gruvbox truecolor PS1
GB_RED='\[\e[38;2;251;73;52m\]'
GB_YELLOW='\[\e[38;2;250;189;47m\]'
GB_GREEN='\[\e[38;2;184;187;38m\]'
GB_BLUE='\[\e[38;2;131;165;152m\]'
GB_PURPLE='\[\e[38;2;211;134;155m\]'
GB_RESET='\[\e[0m\]'

git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(git rev-parse --short HEAD 2>/dev/null)
    [ -n "$branch" ] && echo " $branch"
}

get_trimmed_pwd() {
    local current_pwd="${PWD/#$HOME/\~}"
    if [[ "$current_pwd" == "/" ]]; then
        echo "/"
    else
        echo "$current_pwd" | awk -F/ '{if (NF>2) print $(NF-1)"/"$NF; else print $0}'
    fi
}

PS1="${GB_RED}[${GB_YELLOW}\u${GB_GREEN}@${GB_BLUE}\h${GB_RESET} ${GB_GREEN}\$(get_trimmed_pwd)${GB_RESET}${GB_PURPLE}\$(git_branch)${GB_RESET}${GB_RED}]${GB_RESET}\$ "

# My aliases
[ -f $HOME/dotfiles/shell/.bash_aliases ] && . $HOME/dotfiles/shell/.bash_aliases
