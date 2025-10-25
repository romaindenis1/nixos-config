{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    userName = "Romain";
    userEmail = "ps04egl@eduvaud.ch";
  };

  home.file.".gitconfig" = {
    text = ''
[user]
  name = "Romain"
  email = "ps04egl@eduvaud.ch"
[color]
  ui = auto
'';
  };
}
