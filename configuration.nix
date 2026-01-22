{ config, pkgs, lib, pkgs-unstable, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [ 
    "i915.enable_psr=0" 
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  console.keyMap = "sg";

  services.xserver.xkb = {
    layout = "ch";
    variant = "nodeadkeys";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";

    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.r = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # Ensure Hyprland is the only session
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "Hyprland";
        user = "r";
      };
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.zsh.enable = true;
  services.openssh.enable = true;

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      noto-fonts-emoji
      font-awesome
      powerline-fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "obsidian" "vscode" ];

  environment.systemPackages = with pkgs; [
    hyprland
    hyprpaper
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
    networkmanager
    networkmanagerapplet
    alsa-utils
    gnome-power-manager
    networkmanager_dmenu
    obsidian
    vscode
    adwaita-icon-theme
    networkmanagerapplet
    cava
    tty-clock
    pkgs-unstable.gemini-cli
    # Add polkit to system packages to ensure it is available
    polkit
    # Add networkmanager-openconnect to resolve the username issue
    networkmanager-openconnect
  ];

  system.stateVersion = "25.05";
}
