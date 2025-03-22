# modules/hyprland.nix
# configure hyprland wm.

{ config, lib, pkgs, ... }:

{

  services.xserver = {
    enable = true;
  };
  
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
