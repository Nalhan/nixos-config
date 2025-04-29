{ config, lib, pkgs, ...}: 
{
  stylix = {
    enable = true;
    image = ./DSCF5054.jpg; 
    base16Scheme = "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
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
