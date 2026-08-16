{ pkgs, ... }:

let
  mkScript = name: file:
  pkgs.writeScriptBin name (builtins.readFile file);
in
{
  home.packages = [
    (mkScript "ziad-toggle-darkmode"  ./toggle-darkmode.sh)
    (mkScript "ziad-screenshot"       ./screenshot.sh)
    (mkScript "ziad-screenlayout"     ./screenlayout.sh)
    (mkScript "ziad-random-wallpaper" ./feh.sh)
    (mkScript "ziad-brightness"       ./brightness.sh)
    (mkScript "ziad-open-dired-home"  ./open-dired-home.sh)
    (mkScript "ziad-i3lock"           ./i3lock.sh)
    (mkScript "ziad-make-desktop"     ./make_desktop.sh)

    (mkScript "ziad-power-manager" ./power_manager.sh)

    pkgs.xrandr
  ];
}
