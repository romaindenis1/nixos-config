{ config, pkgs, lib, configRoot, ... }:

{
  xdg.configFile."matugen".source =
    config.lib.file.mkOutOfStoreSymlink "${configRoot}/config/programs/matugen";
}
