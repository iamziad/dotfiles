function git_branch
    set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$branch"
        set branch (git rev-parse --short HEAD 2>/dev/null)
    end
    if test -n "$branch"
        echo " $branch"
    end
end
