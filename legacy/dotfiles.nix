{ config, pkgs, lib, ... }:

let
  # Import repository settings the same way other modules do
  settings = import ../settings.nix;
  dotRepo = if lib.hasAttr "dotfiles" settings && lib.hasAttr "repo" settings.dotfiles then settings.dotfiles.repo else "";
in

{
  # Activation script: clone or update the repo, then deploy/symlink dotfiles
  home.activation.deployDotfiles = {
    text = ''
#!/bin/sh
set -e
DOT_REPO_URL='${dotRepo}'
if [ -z "$DOT_REPO_URL" ]; then
  echo "No dotfiles repo configured; skipping dotfiles deployment"
  exit 0
fi

DOT="$HOME/.dotfiles"
if [ -d "$DOT/.git" ]; then
  echo "Updating dotfiles in $DOT"
  git -C "$DOT" fetch --all --prune
  git -C "$DOT" reset --hard origin/HEAD || true
else
  echo "Cloning dotfiles $DOT_REPO_URL to $DOT"
  git clone --depth 1 "$DOT_REPO_URL" "$DOT"
fi

# Symlink top-level dotfiles (skip common repo cruft)
for f in "$DOT"/.[!.]* "$DOT"/..?*; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  case "$name" in
    .|..|.git|.gitignore|.gitmodules|.DS_Store|README*|LICENSE*) continue ;;
  esac
  target="$HOME/$name"
  if [ -L "$target" ]; then rm "$target"; fi
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.backup.$(date +%s)"
  fi
  ln -s "$f" "$target"
done

# If repo contains a 'home' directory, copy/merge it into $HOME
if [ -d "$DOT/home" ]; then
  rsync -a --backup --suffix=".backup.$(date +%s)" "$DOT/home/" "$HOME/"
fi

# If repo contains a 'config' directory, merge into $HOME/.config
if [ -d "$DOT/config" ]; then
  mkdir -p "$HOME/.config"
  rsync -a --backup --suffix=".backup.$(date +%s)" "$DOT/config/" "$HOME/.config/"
fi

echo "Dotfiles deploy complete."
'';
  };

}
