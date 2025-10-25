{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    # Oh My Zsh support isn't provided as `programs.zsh.ohMyZsh` by this Home Manager setup.
    # If you want Oh My Zsh, install it via `home.packages` and source it in your .zshrc, or
    # use Home Manager's `programs.zsh` options documented in your Home Manager release.
  };

  # `home.shells` is not a Home Manager option; remove it to avoid undefined-option errors.
  # home.shells = [ pkgs.zsh ];
  # Add zsh plugins for autosuggestions and syntax highlighting
  home.packages = with pkgs; [ zsh-autosuggestions zsh-syntax-highlighting ];

  home.file.".zshrc" = {
    text = ''
# .zshrc - managed by home-manager
export ZDOTDIR=$HOME/.config/zsh
source $HOME/.nix-profile/etc/profile.d/nix.sh

# Load zsh-autosuggestions if available
if [ -f '${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' ]; then
  source '${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'
fi

# Load zsh-syntax-highlighting if available
if [ -f '${pkgs.zsh-syntax-highlighting}/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ]; then
  source '${pkgs.zsh-syntax-highlighting}/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
fi
'';
  };
}
