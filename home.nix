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

  home.username = settings.home.username;
  home.homeDirectory = settings.home.directory;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    git
    unzip
    zsh

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

    noto-fonts
  ];
}
