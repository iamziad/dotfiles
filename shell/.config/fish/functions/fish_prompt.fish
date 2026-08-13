function fish_prompt
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
end
