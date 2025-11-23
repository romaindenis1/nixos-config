{ config, lib, pkgs, inputs, ... }:

{
  # System config for Hyprland
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;

  # Display Manager (SDDM)
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "hyprland";

  # Optional: Hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Home Manager config for Hyprland
  home-manager.users.r = { pkgs, ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      
      settings = {
        "$mod" = "SUPER";
        
        monitor = ",preferred,auto,1";

        bind = [
          "$mod, Q, exec, kitty"
          "$mod, M, exit,"
          "$mod, C, killactive,"
          "$mod, V, togglefloating,"
          "$mod, R, exec, wofi --show drun"
        ];
      };
    };
  };
}
