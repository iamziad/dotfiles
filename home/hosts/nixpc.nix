{ ... }:

# home-manager profile for ziad@nixpc. A future laptop/headless host
# would get its own file here importing only ../common.nix.

{
  imports = [
    ../home.nix
    ../desktop-minimal.nix
  ];

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///mnt/hdd hdd
  '';
}
