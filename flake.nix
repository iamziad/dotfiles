{
  description = "Ziad's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
  let
    system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations.nixpc = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        (if builtins.pathExists ./secrets.nix then ./secrets.nix else { })
      ];
    };

    homeConfigurations.ziad = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
    };
  };
}
