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
      nrs = "cd ~/dotfiles && sudo nixos-rebuild switch --flake .";
      hms = "cd ~/dotfiles && home-manager switch -b backup --flake .";
    } // gitAliases // tmuxAliases // emacsAliases // {
      emacs-kill = "emacsclient -e '(kill-emacs)'";
      emacs-start = "emacs --daemon";
      emacs-reload = "emacsclient -e '(kill-emacs)' 2>/dev/null; sleep 0.3; emacs --daemon";
    };

    interactiveShellInit = ''
      set -g fish_greeting ""
    '';

    functions = {
      prompt_is_dark_mode = ''
        set -l settings "$HOME/.config/gtk-3.0/settings.ini"
        set -l line (grep "gtk-theme-name" "$settings" 2>/dev/null)
        test -z "$line"; and return 0
        string match -q "*-dark*" -- "$line"
      '';

      fish_prompt = ''
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
        echo -n (nix_shell_indicator 8ec07c)
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
        echo -n (nix_shell_indicator 2f573e)
        set_color 9d0006
        echo -n "]"
        set_color normal
        echo -n "\$ "
        end
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

      nix_shell_indicator = ''
        set -l color $argv[1]
        test -n "$color"; or set color 8ec07c
        if set -q IN_NIX_SHELL
        set_color $color
        if set -q prompt
        echo -n "  $prompt"
        else
        echo -n "  nix"
        end
        set_color normal
        end
      '';
    };
  };
}
