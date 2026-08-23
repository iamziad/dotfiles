{ pkgs, ... }:

{
  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///mnt/hdd hdd
  '';

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
}
