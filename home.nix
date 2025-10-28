{ config, pkgs, ... }:

let
  # Prefer local untracked settings; fallback on example
  repoSettings = ./settings.nix.example;
  userSettingsPath = "${builtins.getEnv "HOME"}/.config/nix/settings.nix";
  settings = if builtins.pathExists userSettingsPath then
               import userSettingsPath
             else if builtins.pathExists repoSettings then
               import repoSettings
             else
               abort ("No settings found: create " + userSettingsPath + " or add ./settings.nix (or settings.nix.example)");
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
