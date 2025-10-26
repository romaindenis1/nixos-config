{ config, pkgs, lib, ... }:

let
  settings = import ../settings.nix;
in

{
  programs.git = {
    enable = true;
    userName = settings.git.name;
    userEmail = settings.git.email;
  };

  home.file.".gitconfig" = {
    text = ''
[user]
  name = "${settings.git.name}"
  email = "${settings.git.email}"
[color]
  ui = auto
'';
  };
}
