# NixOS / Home Manager config

This repository contains a modular Home Manager configuration. Use as a flake or import the modules directly.

Usage (flake)

- Apply for a user defined in `home.nix`:

  nix run github:nix-community/home-manager -c home-manager switch --flake .#your-username

- Or with an installed home-manager:

  home-manager switch --flake .#your-username

Activation

- Standalone Home Manager (no flakes):
  ```bash
  home-manager switch -f ./home.nix
  ```

- Use nix shell to run Home Manager (flake):
  ```bash
  nix shell github:nix-community/home-manager -c home-manager switch --flake .#your-username
  ```
  Replace `your-username` with the flake output/username.

- Use nix (with experimental features) to run Home Manager (flake):
  ```bash
  nix --extra-experimental-features "nix-command flakes" shell github:nix-community/home-manager -c "home-manager switch --flake .#your-username"
  ```

- Use nix shell to run a NixOS rebuild as root (flake):
  ```bash
  sudo nix shell nixpkgs#nixos-rebuild -c nixos-rebuild switch --flake .#your-hostname -I nixos-config=.
  ```
  Replace `your-hostname` with the flake entry for your machine.

Structure

- `home.nix` - top-level Home Manager configuration that imports `modules/*`.
- `modules/` - per-feature modules (theme, shell, bar, hyprland, browser, git, fonts, menu).
- `flake.nix` - (optional) pins `nixpkgs` and `home-manager` when using flakes.

Notes

- Keep package lists centralized in `home.nix` if multiple modules require the same packages to avoid accidental overrides.
- Choose either the flake approach or system-level Home Manager NixOS module; do not mix both unless you know what you're doing.
