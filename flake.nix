{
  description = "Home manager for r";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      systems = [ "x86_64-linux" ];
      pkgsFor = system: import nixpkgs { inherit system; };
      hm = home-manager.lib;
    in {
      # Home Manager configurations
      homeConfigurations = {
        r = hm.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-linux";
          modules = [ ./home.nix ];
        };
      };

      # Base desktop 
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/desktop.nix ];
        };

        # WSL
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/wsl.nix ];
        };
      };
    };
}
