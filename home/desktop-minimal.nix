{ config, pkgs, ... }:

# Everything X11/i3-desktop specific. Only import this on a machine that
# actually runs the i3 desktop (see home/hosts/nixpc.nix). A future
# headless or WSL profile would import home/common.nix alone.

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  sym = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [
    ./services/picom.nix
    ./services/dunst.nix
  ];

  dconf.enable = false;

  # Programs whose config is large/changes a lot: kept as plain files in
  # config/ and symlinked in, instead of modeled as Nix options.
  xdg.configFile = {
    "i3".source        = sym "config/i3"; # WM
    "alacritty".source = sym "config/alacritty";
  };

  xdg.dataFile."applications/feh.desktop".source = sym "config/feh.desktop";

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

  xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
    Net/ThemeName "Adwaita-dark"
    Net/IconThemeName ""
    Gtk/CursorThemeName "Adwaita"
    Gtk/CursorThemeSize 24
    Gtk/ApplicationPreferDarkTheme 0
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

      "image/jpeg"    = "feh.desktop";
      "image/png"     = "feh.desktop";
      "image/webp"    = "feh.desktop";
      "image/bmp"     = "feh.desktop";
      "image/tiff"    = "feh.desktop";
      "image/svg+xml" = "feh.desktop";

      "video/mp4"        = "mpv.desktop";
      "video/mpeg-4"     = "mpv.desktop";
      "video/mkv"        = "mpv.desktop";
      "video/webm"       = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/avi"        = "mpv.desktop";
      "video/quicktime"  = "mpv.desktop";
      "video/x-flv"      = "mpv.desktop";

      "text/plain"         = "emacsclient.desktop";
      "text/x-csrc"        = "emacsclient.desktop";
      "text/x-python"      = "emacsclient.desktop";
      "text/x-java"        = "emacsclient.desktop";
      "text/x-shellscript" = "emacsclient.desktop";
      "text/css"           = "emacsclient.desktop";
      "text/x-makefile"    = "emacsclient.desktop";
    };

    associations.added = {
      "text/plain" = "emacsclient.desktop";
    };
  };
}
