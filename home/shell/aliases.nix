{
  gitAliases = {
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gl = "git log";
    gd = "git diff";
  };

  tmuxAliases = {
    tl = "tmux list-sessions";
    ta = "tmux attach-session -t";
    tn = "tmux new-session -s";
    tk = "tmux kill-session -t";
  };

  emacsAliases = {
    ecf = "emacsclient -c";
    ect = "emacsclient -t";
    et  = "emacs -nw";
    ed  = "ect .";
  };
}
