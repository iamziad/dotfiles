{ pkgs, ... }:

let
  mkScript = name: file:
  pkgs.writeScriptBin name (builtins.readFile file);
in
{
  home.packages = [
    # can get called individually
    (mkScript "my-toggle-darkmode"  ./toggle-darkmode.sh)
    (mkScript "my-screenshot"       ./screenshot.sh)
    (mkScript "my-screenlayout"     ./screenlayout.sh)
    (mkScript "my-random-wallpaper" ./feh.sh)
    (mkScript "my-brightness"       ./brightness.sh)
    (mkScript "my-i3lock"           ./i3lock.sh)
    (mkScript "my-xautolock"        ./xautolock.sh)
    # called by other scripts
    (mkScript "my-suspend-notify" ./suspend_notify.sh)

    pkgs.xrandr
  ];
}
