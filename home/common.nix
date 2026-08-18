{ config, pkgs, ... }:

# Anything here should work on ANY machine you drop this repo onto,
# desktop, laptop, or a bare SSH box: shell, git, scripts, terminal
# editors. Nothing X11/GUI-specific belongs in this file — see desktop.nix.

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  sym = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [
    ./shell/shell.nix
    ./scripts/scripts.nix
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

  home.file = {
    ".clang-format".source = sym "config/clang-format";
  };

  # large/changes a lot
  xdg.configFile = {
    "emacs".source     = sym "config/emacs";
    "vim/vimrc".source = sym "config/vim/vimrc";
  };

  services.emacs = {
    enable = true;
    client.enable = true;
  };

  programs.git = {
    enable = true;

    settings  = {
      user = {
        name = "Ziad Ahmed";
        email = "dev.ziadahmed@gmail.com";
      };

      core = {
        editor = "emacsclient -r";
      };

      init = {
        defaultBranch = "main";
      };
    };

    ignores = [
      # --- Vim ---
      "*.swp"
      "*.swo"
      "*~"
      ".netrwhist"
      "undo/"

      # --- Emacs ---
      "\\#*\\#"
      "/.emacs.desktop"
      "/.emacs.desktop.lock"
      ".elc"
      "auto-save-list/"
      "tramp"
      ".\\#*"
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
