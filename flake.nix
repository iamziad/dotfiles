{
  description = "Ziad's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # One entry per machine. To add a new host:
    #   1. mkdir hosts/<name>, generate hardware-configuration.nix there
    #      (nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix)
    #   2. write hosts/<name>/configuration.nix (import ../common.nix, set networking.hostName,
    #      set system.stateVersion to the release you're installing, add anything machine-specific)
    #   3. add a matching line below
    nixosConfigurations = {
      nixpc = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/nixpc/configuration.nix ];
      };
    };

    # One entry per user@host. To add a new one:
    #   1. write home/hosts/<name>.nix (import ../common.nix, and ../desktop.nix if it's a GUI machine)
    #   2. add a matching line below
    homeConfigurations = {
      "ziad@nixpc" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/hosts/nixpc.nix ];
      };
    };
  };
}
