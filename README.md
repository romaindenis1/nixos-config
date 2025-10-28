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

Settings

- This repository includes a template `settings.nix.example` meant for public configuration.
- For private/secret values (e.g. email, API keys, timezone), place an untracked `settings.nix` at `~/.config/nix/settings.nix`.
- `home.nix` prioritses this file, and if not found, will fallback to the tracked settings in this repo

You can create the untracked local settings file from the example with:

```bash
mkdir -p "$HOME/.config/nix" && cp settings.nix.example "$HOME/.config/nix/settings.nix" && chmod 600 "$HOME/.config/nix/settings.nix"
```

Structure

- `home.nix` - top-level Home Manager configuration that imports `modules/*`.
- `modules/` - per-feature modules (theme, shell, bar, hyprland, browser, git, fonts, menu).
- `flake.nix` - (optional) pins `nixpkgs` and `home-manager` when using flakes.

Notes

- Keep package lists centralized in `home.nix` if multiple modules require the same packages to avoid accidental overrides.
- Choose either the flake approach or system-level Home Manager NixOS module; do not mix both unless you know what you're doing.




nix-shell -p home-manager -b backup --run 'home-manager switch -f ./home.nix'
nix-shell -p home-manager --run 'home-manager switch -f ./home.nix -b backup'