{ config, pkgs, inputs, ... }:

{
  imports = [
    # User specific modules can go here
  ];

  home.username = "r";
  home.homeDirectory = "/home/r";

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # User apps
    firefox
    discord
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
