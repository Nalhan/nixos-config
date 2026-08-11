{ pkgs, ... }:
{
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
  };

  xdg.configFile."niri/config.kdl".source = ../../dotfiles/niri/config.kdl;

  home.packages = with pkgs; [
    grim
    slurp
  ];
}
