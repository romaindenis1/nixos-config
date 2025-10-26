{ config, pkgs, ... }:

let
  settings = import ./settings.nix;
in

{
  imports = [
    ./modules/core.nix
    ./modules/browser.nix
    ./modules/theme.nix
    ./modules/fonts.nix
    ./modules/shell.nix
    ./modules/git.nix
  ];

  home.username = settings.username;
  home.homeDirectory = settings.homeDirectory;

  programs.home-manager.enable = true;

  # Example of enabling services or packages commonly used across modules
  home.packages = with pkgs; [
    # editor / tooling
    neovim
    git
    unzip
    zsh

    # utilities from modules
    diff-so-fancy
    waybar
    hyprland
    mako
    wl-clipboard
    grim
    slurp
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    zsh-autosuggestions
    zsh-syntax-highlighting
    arc-theme
    chromium

    # fonts and launchers
    noto-fonts
    noto-fonts-cjk
    jetbrains-mono
    wofi
    bemenu
  ];

  # Set some sensible defaults you can override in modules
  xdg.configHome = "${config.home.homeDirectory}/.config";
}
