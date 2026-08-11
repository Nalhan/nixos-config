{ lib, ... }:
{
  imports = [ ../../modules/hardware/generic-disk.nix ];

  nalhan.install.bootMode = lib.mkDefault "bios";
}
