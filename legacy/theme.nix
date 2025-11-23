{ config, pkgs, lib, ... }:

{
  # GTK and icon theme
  # NOTE: `programs.gnome3` is a NixOS system option, not a Home Manager option.
  # If you need to enable GNOME in system config, set it in /etc/nixos/configuration.nix.

  home.packages = with pkgs; [
    arc-theme
  ];

  home.file.".config/gtk-3.0/settings.ini" = {
    text = ''
[Settings]
gtk-theme-name = Arc-Dark
gtk-icon-theme-name = Adwaita
'';
  };

  # GTK4 settings
  home.file.".config/gtk-4.0/settings.ini" = {
    text = ''
[Settings]
gtk-theme-name = Arc-Dark
'';
  };

  # Cursor theme (set default cursor)
  home.file.".icons/default/index.theme" = {
    text = ''
[Icon Theme]
'';
  };

  # Synthwave palette GTK overrides
  home.file.".config/gtk-3.0/gtk.css" = {
    text = ''
@define-color accent #7C4DFF;
@define-color accent-2 #FF6AC1;
@define-color accent-3 #FF8A00;
@define-color bg #0B0F1A;
@define-color fg #E6E6FA;

window, headerbar {
  background-color: @bg;
  color: @fg;
}
headerbar {
  background-gradient: vertical(#0B0F1A, #101224);
}
button, .link {
  color: @accent-2;
}
.entry, textview {
  background-color: #0E1220;
  color: @fg;
}
'';
  };

}
