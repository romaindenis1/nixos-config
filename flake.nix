{
  description = "Minimal NixOS flake testttt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      # Configured nixpkgs WITH unfree predicate
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (pkgs.lib.getName pkg) [
            "vscode"
            "vscode-wayland"
            "obsidian"
          ];
      };
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;

        # Pass pkgs and any extras to your module
        specialArgs = { inherit pkgs; };

        modules = [
          # Your actual system config
          ./hosts/default/configuration.nix

          # Add the unfree config as a module to ensure it is applied
          {
            nixpkgs.config.allowUnfreePredicate = pkg:
              builtins.elem (pkgs.lib.getName pkg) [
                "vscode"
                "vscode-wayland"
                "obsidian"
              ];
          }
        ];
      };
    };
}

