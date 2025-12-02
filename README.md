# Minimal NixOS — Hyprland only

This repository is configured to be minimal and to run Hyprland only. The intent is to keep the system free of KDE, Home Manager, and any other desktop environments or optional modules.

Quick steps to enable only Hyprland

1. Edit `hosts/default/configuration.nix` and set these two entries to only include Hyprland:

   - Replace `environment.systemPackages` with:
     ```nix
     environment.systemPackages = with pkgs; [ hyprland ];
     ```

   - Replace the per-user package list with:
     ```nix
     users.users.r.packages = with pkgs; [ hyprland ];
     ```

   Remove any other packages, desktop managers, or Home Manager imports.

2. (Optional) Generate hardware config if missing:

   ```bash
   nixos-generate-config --show-hardware-config > hosts/default/hardware-configuration.nix
   ```

3. Rebuild the system:

   ```bash
   nixos-rebuild switch --flake .#default
   ```

If you want me to automatically edit `hosts/default/configuration.nix` to leave only Hyprland and remove everything else, say so and I'll make the change.