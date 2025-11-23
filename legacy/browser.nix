{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    # Note: to add browser extensions or helper packages, add them to `home.packages`
    # or manage browser prefs via a `home.file` (user.js) instead of using a non-existent
    # `extraPackages` option.
  };

}
