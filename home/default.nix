{ inputs, pkgs, ... }:
{
  imports = [
    ./profiles/cli.nix
  ];

  home = {
    username = "bread";
    homeDirectory = "/home/bread";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
