{
  description = "Merged NixOS flake: current base + quickshell bar/widgets from incoming";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";

      # Absolute filesystem path where this config is deployed. Used by
      # mkOutOfStoreSymlink and by scripts that live outside the nix store.
      # Default is the standard NixOS location; change here if you deploy
      # this tree somewhere else.
      configRoot = "/etc/nixos";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (pkgs.lib.getName pkg) [
            "vscode"
            "vscode-wayland"
            "obsidian"
            "steam"
            "steam-unwrapped"
          ];
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      mkHost = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit pkgs configRoot;
          pkgs-unstable = pkgs-unstable;
        };

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit configRoot; };
            home-manager.users.r = import ./home.nix;
          }
          {
            nixpkgs.config.allowUnfreePredicate = pkg:
              builtins.elem (pkg.lib.getName pkg) [
                "vscode"
                "vscode-wayland"
                "obsidian"
              ];
          }
        ];
      };
    in {
      nixosConfigurations = {
        default = mkHost;
        nixos = mkHost;
      };
    };
}
