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
    # Incoming config uses options (float_gaps, gesture) only in newer Hyprland.
    package = pkgs-unstable.hyprland;
    portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;
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
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      noto-fonts-emoji
      font-awesome
      powerline-fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      udev-gothic-nf
    ];
  };

  programs.gamemode.enable = true;

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
    obsidian
    vscode
    adwaita-icon-theme
    networkmanagerapplet
    cava
    tty-clock
    pkgs-unstable.gemini-cli
    pkgs-unstable.ryubing
    steam-run
    vulkan-tools
    # Add polkit to system packages to ensure it is available
    polkit
    # Add networkmanager-openconnect to resolve the username issue
    networkmanager-openconnect
    unzip

    # Quickshell bar/widgets stack (lifted from nixos-config-incoming).
    # quickshell and matugen are recent; pull from unstable.
    pkgs-unstable.quickshell
    pkgs-unstable.matugen
    swww
    playerctl
    grim
    slurp
    satty
    swappy
    cliphist
    pamixer
    brightnessctl
    socat
    jq
    yq-go
    imagemagick
    libnotify
    acpi
    lm_sensors
    bc
    fd
    ripgrep
    qt6.qtmultimedia
    qt6.qt5compat
    qt6.qtwebsockets
  ];

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "r" ];

  system.stateVersion = "25.05";
}
