{ config, pkgs, ... }:

{
  # Core packages installed on all systems
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
  ];
}
