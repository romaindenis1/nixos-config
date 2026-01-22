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

# If we're in a git repo, add and commit the generated hardware file so flakes include it.
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Detected git repository at $REPO_ROOT — adding hardware file to git"
  cd "$REPO_ROOT"
  git add --force "$HW_PATH"
  if git diff --cached --quiet; then
    echo "No changes to commit"
  else
    if git commit -m "chore: add/update generated hardware-configuration.nix"; then
      echo "Committed hardware config"
    else
      echo "Failed to commit hardware config. Please ensure git user.name and user.email are configured and try again."
      exit 1
    fi
  fi
else
  echo "Not a git repository — skipping commit. Note: flakes may not include uncommitted files." 
fi

echo "Running nixos-rebuild switch --flake $FLAKE_URI"
sudo nixos-rebuild switch --flake "$FLAKE_URI"

echo "Done."
