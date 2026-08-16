{ config, pkgs, lib, ... }:

let
  inherit (import ./aliases.nix) gitAliases tmuxAliases emacsAliases;
in
{
  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color";
      rm = "rm -i";
      mvn = ''mvn -gs $XDG_CONFIG_HOME/maven/settings.xml'';
    };

    shellAbbrs = {
      c = "xclip -selection clipboard";
      nrs = "sudo nixos-rebuild switch";
    } // gitAliases // tmuxAliases // emacsAliases // {
      emacs-kill = "emacsclient -e '(kill-emacs)'";
      emacs-start = "emacs --daemon";
      emacs-reload = "emacsclient -e '(kill-emacs)' 2>/dev/null; sleep 0.3; emacs --daemon";
    };

    interactiveShellInit = ''
      set -g fish_greeting ""
    '';

    functions = {
      fish_prompt = ''
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
      '';

      get_trimmed_pwd = ''
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
      '';

      git_branch = ''
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
        if test -z "$branch"
        set branch (git rev-parse --short HEAD 2>/dev/null)
        end
        if test -n "$branch"
        echo " $branch"
        end
      '';
    };
  };
}
