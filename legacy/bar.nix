{ config, pkgs, lib, ... }:

{
  # Ensure waybar is available — the hyprland module already adds it, but listing here
  # in case the user enables bar without the full hyprland module.
  home.packages = with pkgs; [ waybar ];

  # Waybar configuration (minimal)
  home.file.".config/waybar/config" = {
    text = ''
* {
  font-family: "Inter", sans-serif;
  color: #E6E6FA;
}
window .bar {
  background: rgba(11,15,26,0.85); /* #0B0F1A with slight transparency */
  border-bottom: 1px solid rgba(124,77,255,0.12);
}
.module {
  padding: 6px 10px;
  color: #E6E6FA;
}
.module:hover {
  background: rgba(124,77,255,0.06);
}
#clock { color: #FF6AC1; }       /* pink */
#network { color: #FF8A00; }     /* orange */
#pulseaudio { color: #7C4DFF; }  /* purple */
'';
  };

  # Example custom module (workspace names) — a tiny script
  home.file.".config/waybar/scripts/workspace-names.sh" = {
    text = ''
#!/usr/bin/env bash
# simple placeholder that echos workspace names; replace with a real script if needed
echo "1:dev 2:web 3:term"
'';
    executable = true;
  };

}
