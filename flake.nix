{
  description = "Home Manager for r";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      settingsPath = builtins.path { path = ./settings.nix; };
      hm = home-manager.lib;
    in {
      homeConfigurations = {
        r = hm.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix settingsPath ];
        };
      };
    };
}
