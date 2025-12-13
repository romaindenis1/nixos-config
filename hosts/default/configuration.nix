{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ==========================================
  # 1. CRITICAL HARDWARE FIXES (The "Jitter" Fix)
  # ==========================================
  
  # ThinkPad E14 Gen 7 is too new for the default kernel. 
  # We MUST use the latest kernel for smooth graphics.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Fixes screen stutter/flicker common on ThinkPads (Intel Graphics)
  boot.kernelParams = [ 
    "i915.enable_psr=0" 
  ];

  # Enable Graphics Drivers (OpenGL/Vulkan)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver   # For Intel GPUs (Broadwell+)
      libvdpau-va-gl
    ];
  };

  # ==========================================
  # 2. KEYBOARD (Swiss Fix)
  # ==========================================
  
  # This sets the layout for the console (before you login)
  console.keyMap = "sg"; # 'sg' is the code for Swiss German in console

  # This sets the layout for X11 and Hyprland
  services.xserver.xkb = {
    layout = "ch";
    variant = "nodeadkeys"; # This makes ~ and ^ type immediately
  };

  # ==========================================
  # 3. HYPRLAND CONFIGURATION
  # ==========================================

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Fixes for Electron apps (Obsidian, VSCode) to stop them from lagging
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1"; # Use this if your cursor is invisible or glitchy
  };

  # ==========================================
  # 4. SYSTEM BASICS
  # ==========================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # ==========================================
  # 5. USER & PACKAGES
  # ==========================================

  users.users.r = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
    shell = pkgs.zsh;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "r";
      };
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.zsh.enable = true;
  services.openssh.enable = true;


  
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "obsidian" "vscode" ];
  
  environment.systemPackages = with pkgs; [
    hyprland
    waybar
    kitty
    rofi-wayland
    wlogout
    wl-clipboard
    zsh
    git
    gh
    neovim
    neofetch
    ncmpcpp
    firefox
    qbittorrent
    vlc

    obsidian
    vscode
  ];

  system.stateVersion = "25.05";
}
