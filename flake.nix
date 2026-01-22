{
  description = "Minimal NixOS flake testttt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
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
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;

        # Pass pkgs and any extras to your module
        specialArgs = { inherit pkgs; pkgs-unstable = pkgs-unstable; };

        modules = [
          # Your actual system config
          ./configuration.nix

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

