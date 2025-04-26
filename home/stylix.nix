{ config, lib, pkgs, ...}: 
{
  stylix = {
    enable = true;
    image = ./DSCF5054.jpg; 
    base16Scheme = "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    targets = {
      kde.enable = true;
      swaync.enable = false;
      #hyprland.enable = false;
      vesktop.enable = true;
      firefox = {
        profileNames = [
          "vg3xfiux.default"
        ];
      };
    };
  };
}
