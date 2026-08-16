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
