{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/core/default.nix
    ../../modules/desktop/hyprland/default.nix
    ../../modules/programs/kitty.nix
    # Include hardware scan if available. 
    # You should generate this with 'nixos-generate-config' or copy your existing one.
    # ./hardware-configuration.nix
    
    # Import secrets if they exist
    (if builtins.pathExists ../../secrets/secrets.nix then ../../secrets/secrets.nix else {})
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account.
  users.users.r = {
    isNormalUser = true;
    description = "r";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.11";
}
