{ config, pkgs, lib, configRoot, ... }:

{
  imports = [
    # Quickshell bar + widgets + supporting Hyprland session bits,
    # lifted from nixos-config-incoming.
    ./config/sessions/hyprland/default.nix
    ./config/programs/matugen/default.nix
  ];

  home.username = "r";
  home.homeDirectory = "/home/r";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  # Drop the fonts lifted from incoming (JetBrainsMono, Iosevka NF) into
  # the user font dir so quickshell / kitty / rofi pick them up.
  home.file.".local/share/fonts/" = {
    source = ./config/fonts;
    recursive = true;
  };
}
