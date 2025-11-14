{ config, pkgs, lib, ... }:

let
  # User settings by default
  repoSettings = ./settings.nix.example;
  userSettingsPath = "${builtins.getEnv "HOME"}/.config/nix/settings.nix";
  settings = if builtins.pathExists userSettingsPath then
               import userSettingsPath
             else
               import repoSettings;
in

{
  imports = [
    ../modules/core.nix
    ../modules/shell.nix
    ../modules/git.nix
    ../modules/browser.nix
    ../modules/compositor.nix
    ../modules/theme.nix
    ../modules/fonts.nix
  ];

  # Host identity
  networking.hostName = "desktop";

  services.xserver.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  users.users = {
    "${settings.home.username}" = {
      isNormalUser = true;
      description = "${settings.userFullName or settings.home.username}";
      home = settings.home.directory;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    firefox
    zsh
  ];

  security.sudo.enable = true;

  # elogind for Wayland
  services.elogind.enable = true;
}
