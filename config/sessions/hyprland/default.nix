{ config, pkgs, lib, configRoot, ... }:

{
  imports = [
    ./hypridle.nix
  ];

  # System (programs.hyprland) provides the binary. HM's hyprland module
  # would pull in a duplicate package, so write the user config file directly.
  xdg.configFile."hypr/hyprland.conf".text = ''
    source = ${configRoot}/config/sessions/hyprland/hyprland.conf
  '';

  home.packages = with pkgs; [
    rofi
    pavucontrol
    fortune
    wl-screenrec
    alsa-utils
    swww
    networkmanager_dmenu
    wl-clipboard
    fd
    qt6.qtmultimedia
    qt6.qt5compat
    qt6.qtwebsockets
    ripgrep
    gtk3
    cava
    cliphist
    tree
    jq
    socat
    pamixer
    brightnessctl
    acpi
    iw
    bluez
    libnotify
    networkmanager
    lm_sensors
    bc
    pulseaudio
    ladspaPlugins
    ladspa-sdk
    imagemagick
  ];

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.file.".config/hypr/scripts".source =
    config.lib.file.mkOutOfStoreSymlink "${configRoot}/config/sessions/hyprland/scripts";

  home.activation.copyHyprConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.rsync}/bin/rsync -a --update ${configRoot}/config/sessions/hyprland/config/ $HOME/.config/hypr/config/
      chmod -R u+w $HOME/.config/hypr/config
      # Seed empty colors.conf so hyprland.conf:4 source= doesn't error on
      # first boot before matugen has generated its real contents.
      [ -e $HOME/.config/hypr/colors.conf ] || : > $HOME/.config/hypr/colors.conf
  '';
}
