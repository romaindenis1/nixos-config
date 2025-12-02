{
  description = "Minimal NixOS flake testttt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      # Import a base nixpkgs to get `lib` without any custom config
      base = import nixpkgs { inherit system; };
      # Import nixpkgs again, but pass a config that allows only obsidian as unfree
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkg: base.lib.getName pkg == "obsidian";
        };
      };
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/default/configuration.nix ];
        specialArgs = { inherit pkgs; };
      };
    };
}
