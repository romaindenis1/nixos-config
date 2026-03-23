#!/usr/bin/env bash
set -euo pipefail

# apply-hw-and-rebuild.sh
# Generates a hardware-configuration.nix for the host and runs nixos-rebuild --flake to apply.

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
HW_PATH="$REPO_ROOT/hardware-configuration.nix"
HOSTNAME="default"
FLAKE_URI="$REPO_ROOT#$HOSTNAME"

if [ ! -f "$REPO_ROOT/flake.nix" ]; then
  echo "error: flake.nix not found in $REPO_ROOT"
  exit 1
fi

echo "Generating hardware configuration -> $HW_PATH"

# Run generator as root and write file, then chown back to the invoking user
sudo nixos-generate-config --show-hardware-config | sudo tee "$HW_PATH" > /dev/null
sudo chown "$(id -u):$(id -g)" "$HW_PATH"

echo "Running nixos-rebuild switch --flake $FLAKE_URI"
sudo nixos-rebuild switch --flake "$FLAKE_URI"

echo "Done."
