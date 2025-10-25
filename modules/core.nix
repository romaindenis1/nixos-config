{ config, pkgs, lib, ... }:

{
  # Core settings shared across modules
  home.stateVersion = "23.11"; # update to match your Home Manager / NixOS

  programs.git.enable = true;

  # Example: enable diff-so-fancy globally
  home.packages = with pkgs; [ diff-so-fancy ];

  # Simple dotfiles management example
  home.file = {
    ".profile" = {
      text = ''
# ~/.profile - appended by home-manager
export PATH="$HOME/.local/bin:$PATH"
'';
    };
  };
}
