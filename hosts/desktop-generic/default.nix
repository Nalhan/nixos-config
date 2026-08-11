{ inputs, lib, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk.nix
    ../../modules/core
    ../../modules/roles/cli.nix
    ../../modules/roles/desktop
    ../../modules/roles/desktop/swap.nix
    ../../users/bread.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
  ++ lib.optional (builtins.pathExists ./local-hardware.nix) ./local-hardware.nix
  ++ lib.optional (builtins.pathExists ./local-installation.nix) ./local-installation.nix;

  networking = {
    hostName = lib.mkDefault "desktop";
    networkmanager.enable = true;
  };
}
