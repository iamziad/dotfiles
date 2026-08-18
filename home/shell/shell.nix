{ ... }:

{
  imports = [
    # ./bash.nix
    ./fish.nix
    ./tmux.nix
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    dconf.enable = true;
  };
}
