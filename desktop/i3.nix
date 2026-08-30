{ pkgs, ... }:

{
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu i3status i3blocks i3lock-color xss-lock dunst libnotify
      picom maim xkb-switch playerctl lxappearance redshift pcmanfm
      pavucontrol lm_sensors ddcutil polkit_gnome feh xsettingsd
    ];
  };
}
