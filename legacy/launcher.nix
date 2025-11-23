{ config, pkgs, lib, ... }:

{
  # Provide a simple launcher module for Wayland (wofi / bemenu)
  home.packages = with pkgs; [ wofi bemenu ];

  # Simple launcher script that prefers wofi, falls back to bemenu
  home.file.".local/bin/launcher" = {
    text = ''#!/usr/bin/env bash
if command -v wofi >/dev/null 2>&1; then
  exec wofi --show drun
elif command -v bemenu >/dev/null 2>&1; then
  exec bemenu-run
else
  echo "No launcher installed (wofi or bemenu)" >&2
  exit 1
fi
'';
    executable = true;
  };

  # Example wofi config
  home.file.".config/wofi/config" = {
    text = ''[settings]
show-icons=true
theme=dracula
'';
  };

  # Example bemenu config
  home.file.".config/bemenu/styles" = {
    text = ''window { border: 1px solid #444; }
item { padding: 6px; }
'';
  };

  # Desktop entry to expose launcher to desktop environments
  home.file.".local/share/applications/launcher.desktop" = {
    text = ''[Desktop Entry]
Name=Launcher
Exec=${config.home.homeDirectory}/.local/bin/launcher
Type=Application
Categories=Utility;Application;
'';
  };

}
