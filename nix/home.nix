{ config, pkgs, ... }:
let
  repo = "/home/ziad/dotfiles";
  gui = "${repo}/gui";
  editors = "${repo}/editors";
  shell = "${repo}/shell";
  sym = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.username = "ziad";
  home.homeDirectory = "/home/ziad";

  home.stateVersion = "26.05";

  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.file = {

  };

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  services = {
    xsettingsd = {
      enable = true;
    };

    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      settings = {
        experimental-backends = true;
      };
    };
  };

  dconf.enable = false;

  xdg.configFile = {
    "i3".source = sym "${repo}/gui/i3";
    "emacs".source = sym "${editors}/emacs";
    "vim/vimrc".source = sym "${repo}/editors/vim/vimrc";
    "alacritty/alacritty.toml".source = sym "${gui}/alacritty/alacritty.toml";
    "dunst/dunstrc".source = sym "${gui}/dunst/dunstrc";
    "picom/.picom.conf".source = sym "${gui}/picom/.picom.conf";
    "redshift.conf".source = sym "${gui}/redshift.conf";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ziad/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_DATA_HOME   = "${config.home.homeDirectory}/.local/share";
    XDG_CACHE_HOME  = "${config.home.homeDirectory}/.cache";
    XDG_STATE_HOME  = "${config.home.homeDirectory}/.local/state";

    EDITOR   = "emacsclient";
    TERMINAL = "alacritty";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
