{ config, lib, pkgs, ... }:

{
  home-manager.users.r = { pkgs, ... }: {
    programs.kitty = {
      enable = true;
      theme = "Catppuccin-Mocha";
      font = {
        name = "Fira Code";
        size = 12;
      };
      settings = {
        confirm_os_window_close = 0;
      };
    };
  };
}
