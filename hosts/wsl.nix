{ config, pkgs, ... }:

{
  imports = [
    ../modules/core.nix
    ../modules/shell.nix
    ../modules/git.nix
    # other shared modules
  ];

  # WSL-specific tweaks
  boot.isContainer = true;          
  services = {
    udev.enable = false;            
    xserver.enable = false;         
  };
  
  programs.zsh.enable = true;
}
