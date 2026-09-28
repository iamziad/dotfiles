{ pkgs, ... }:

let
  mkScript = name: file:
  pkgs.writeScriptBin name (builtins.readFile file);
in
{
  home.packages = [
    # can get called individually
    (mkScript "my-toggle-darkmode"  ./my-toggle-darkmode.sh)
    (mkScript "my-screenshot"       ./my-screenshot.sh)
    (mkScript "my-screenlayout"     ./my-screenlayout.sh)
    (mkScript "my-random-wallpaper" ./my-random-wallpaper.sh)
    (mkScript "my-brightness"       ./my-brightness.sh)
    (mkScript "my-i3lock"           ./my-i3lock.sh)
    (mkScript "my-xautolock"        ./my-xautolock.sh)
    (mkScript "my-dim-inactive"     ./my-dim-inactive.sh)
    # called by other scripts
    (mkScript "my-suspend-notify"   ./my-suspend-notify.sh)

    pkgs.xrandr
  ];
}
