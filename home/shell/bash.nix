{ config, pkgs, lib, ... }:

let
  inherit (import ./aliases.nix) gitAliases tmuxAliases emacsAliases;
in
{
  programs.bash = {
    enable = true;
    historyFile = "${config.home.homeDirectory}/.local/state/bash/history";

    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color";
      sudo = "sudo ";
      rm = "rm -i";
      c = "xclip -selection clipboard";
      re = "sudo nixos-rebuild switch";
    } // gitAliases // tmuxAliases // emacsAliases // {
      emacs-kill = ''emacsclient -e "(kill-emacs)"'';
      emacs-start = "emacs --daemon";
      emacs-reload = ''emacsclient -e "(kill-emacs)" 2>/dev/null; sleep 0.3; emacs --daemon'';
    };

    initExtra = ''
      ecw() {
      emacsclient -e "(find-file-other-window \"$1\")"
      }

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
      local current_pwd="''${PWD/#$HOME/\~}"
      if [[ "$current_pwd" == "/" ]]; then
      echo "/"
      else
      echo "$current_pwd" | awk -F/ '{if (NF>2) print $(NF-1)"/"$NF; else print $0}'
      fi
      }

      PS1="''${GB_RED}[''${GB_YELLOW}\u''${GB_GREEN}@''${GB_BLUE}\h''${GB_RESET} ''${GB_GREEN}\$(get_trimmed_pwd)''${GB_RESET}''${GB_PURPLE}\$(git_branch)''${GB_RESET}''${GB_RED}]''${GB_RESET}\$ "
    '';
  };
}
