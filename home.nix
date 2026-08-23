{ config, pkgs, ... }:

{
  imports = [
    ./home/shell/shell.nix
    ./home/scripts/scripts.nix
    ./home/services/picom.nix
    ./home/services/dunst.nix
    ./home/git.nix
    ./home/theme.nix
    ./home/mime.nix
    ./home/dotfiles.nix
    ./home/emacs.nix
    ./home/redshift.nix
  ];

  home.username = "ziad";
  home.homeDirectory = "/home/ziad";
  home.stateVersion = "26.05";

  home.packages = [
    # add ad-hoc packages here
  ];

  home.sessionVariables = {
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_DATA_HOME   = "${config.home.homeDirectory}/.local/share";
    XDG_CACHE_HOME  = "${config.home.homeDirectory}/.cache";
    XDG_STATE_HOME  = "${config.home.homeDirectory}/.local/state";

    EDITOR   = "emacsclient";
    TERMINAL = "alacritty";
  };

  programs.home-manager.enable = true;
}
