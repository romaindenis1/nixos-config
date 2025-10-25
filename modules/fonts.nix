{ config, pkgs, lib, ... }:

{
  # Install fonts into the user profile instead of using the NixOS `fonts.fonts` option
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    jetbrains-mono
  ];

  # Example: write a fonts config
  home.file.".config/fontconfig/fonts.conf" = {
    text = ''
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="scan">
    <test name="family" compare="contains">
      <string>JetBrains Mono</string>
    </test>
  </match>
</fontconfig>
'';
  };
}
