{ config, pkgs, ... }:
let
  source = "../source";
  sym = config.lib.file.mkOutOfStoreSymlink;
in
{
  import = [
    ./services/picom.nix
    ./services/dunst.nix

    ./shell/shell.nix

    ./scripts/scripts.nix
  ];

  home.username = "ziad";
  home.homeDirectory = "/home/ziad";

  home.stateVersion = "26.05";

  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

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
    #
  };

  dconf.enable = false;

  # programs that it's config changes alot
  xdg.configFile = {
    "i3".source = sym "${source}/i3";
    "alacritty".source = sym "${source}/alacritty";
    "emacs".source = sym "${source}/emacs";
    "vim/vimrc".source = sym "${source}/vim/vimrc";
  };

  home.sessionVariables = {
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_DATA_HOME   = "${config.home.homeDirectory}/.local/share";
    XDG_CACHE_HOME  = "${config.home.homeDirectory}/.cache";
    XDG_STATE_HOME  = "${config.home.homeDirectory}/.local/state";

    EDITOR   = "emacsclient";
    TERMINAL = "alacritty";
  };

  services.emacs = {
    enable = true;
    client.enable = true;
  };

  programs.git = {
    enable = true;

    userName  = "Ziad Ahmed";
    userEmail = "dev.ziadahmed@gmail.com";

    extraConfig = {
      core.editor      = "emacsclient -r";
      init.defaultBranch = "main";
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

  gtk = {
    enable = true;

    theme = {
      name    = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name    = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    cursorTheme = {
      name = "Adwaita";
      size = 24;
    };

    font = {
      name = "Adwaita Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
      gtk-toolbar-style       = "GTK_TOOLBAR_BOTH_HORIZ";
      gtk-toolbar-icon-size   = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = 0;
      gtk-menu-images   = 0;
      gtk-enable-event-sounds = 1;
      gtk-enable-input-feedback-sounds = 1;
      gtk-xft-antialias = 1;
      gtk-xft-hinting   = 1;
      gtk-xft-hintstyle = "hintmedium";
      gtk-xft-rgba      = "none";
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
    };
  };

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///mnt/hdd hdd
  '';

  xdg.configFile."redshift.conf".text = ''
    [redshift]
    temp-day=5000
    temp-night=3500
    adjustment-method=randr
    location-provider=manual

    [manual]
    lat=30.0444
    lon=31.2357
  '';

  xresources.properties = {
    "Xcursor.theme" = "Adwaita";
    "Xcursor.size"  = 24;

    "xterm*faceName" = "JetBrainsMono Nerd Font:size=11:antialias=true";

    "xterm*background"   = "#282828";
    "xterm*foreground"   = "#ebdbb2";
    "xterm*cursorColor"  = "#ebdbb2";

    "xterm*scrollBar"      = false;
    "xterm*internalBorder" = 8;
    "xterm*loginShell"     = true;
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "x-scheme-handler/http"  = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "text/html"              = "firefox.desktop";
      "application/pdf"        = "firefox.desktop";

      "image/jpeg"   = "feh.desktop";
      "image/png"    = "feh.desktop";
      "image/webp"   = "feh.desktop";
      "image/bmp"    = "feh.desktop";
      "image/tiff"   = "feh.desktop";
      "image/svg+xml" = "feh.desktop";

      "video/mp4"             = "mpv.desktop";
      "video/mpeg-4"          = "mpv.desktop";
      "video/mkv"             = "mpv.desktop";
      "video/webm"            = "mpv.desktop";
      "video/x-matroska"      = "mpv.desktop";
      "video/avi"             = "mpv.desktop";
      "video/quicktime"       = "mpv.desktop";
      "video/x-flv"           = "mpv.desktop";

      "text/plain"          = "emacsclient.desktop";
      "text/x-csrc"         = "emacsclient.desktop";
      "text/x-python"       = "emacsclient.desktop";
      "text/x-java"         = "emacsclient.desktop";
      "text/x-shellscript"  = "emacsclient.desktop";
      "text/css"            = "emacsclient.desktop";
      "text/x-makefile"     = "emacsclient.desktop";
    };

    associations.added = {
      "text/plain" = "emacsclient.desktop";
    };
  };

  xdg.dataFile."applications/feh.desktop".source = ./../files/applications/feh.desktop;

  xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
    Net/ThemeName "Adwaita-dark"
    Net/IconThemeName ""
    Gtk/CursorThemeName "Adwaita"
    Gtk/CursorThemeSize 24
    Gtk/ApplicationPreferDarkTheme 0
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
