# filepath: /home/r/Downloads/home-manager/flake.nix
{
  description = "Home Manager flake - modular config test";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux"; # change to aarch64-linux if needed
      pkgs = import nixpkgs { inherit system; };
      hm = inputs."home-manager";
    in {
      homeConfigurations = {
        r = hm.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
      };
    };
}
