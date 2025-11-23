 # NixOS Configuration

A modular, flake-based NixOS configuration skeleton.

## Structure

This repository is designed to be modular, allowing you to easily swap Desktop Environments (DEs), Window Managers (WMs), and manage users and secrets.

```
.
├── flake.nix             # Entry point
├── hosts
│   └── default           # Host 'default'
│       ├── configuration.nix # System entry point
│       └── home.nix          # Home Manager entry point
├── modules
│   ├── core              # Core system configuration
│   ├── desktop           # DE/WM configurations
│   │   └── hyprland      # Hyprland module
│   ├── programs          # App configurations
│   └── ...
└── secrets               # Secrets (gitignored)
    └── secrets.nix       # Your secrets file
```

## Features

- **Flakes**: Uses Nix Flakes for reproducible builds.
- **Home Manager**: Manages user dotfiles and packages.
- **Modular**: Easily enable/disable modules in `hosts/default/configuration.nix`.
- **Hyprland**: Pre-configured Hyprland module with Kitty.
- **Secrets**: Separation of secrets from the git repository.

## Installation

1.  **Clone the repository**:
    ```bash
    git clone <your-repo-url> ~/nixos-config
    cd ~/nixos-config
    ```

2.  **Generate Hardware Config**:
    If this is a new machine, generate your hardware configuration:
    ```bash
    nixos-generate-config --show-hardware-config > hosts/default/hardware-configuration.nix
    ```
    Then uncomment the import in `hosts/default/configuration.nix`.

3.  **Setup Secrets**:
    Copy the example secrets file:
    ```bash
    cp secrets/secrets.nix.example secrets/secrets.nix
    ```
    Edit `secrets/secrets.nix` to add your sensitive data.

4.  **Install/Switch**:
    ```bash
    nixos-rebuild switch --flake .#default
    ```

## Customization

### Changing Desktop Environment
To switch from Hyprland to another DE (e.g., KDE):
1.  Create a new module in `modules/desktop/kde/default.nix`.
2.  In `hosts/default/configuration.nix`, comment out the Hyprland import and add the KDE import.

### Adding Packages
- **System-wide**: Add to `modules/core/default.nix` or `hosts/default/configuration.nix`.
- **User-specific**: Add to `hosts/default/home.nix`.

### Managing Dotfiles
This config uses Home Manager. You can define your dotfiles in `home.nix` or create separate modules in `modules/programs/` and import them.