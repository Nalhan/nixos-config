{ config, lib, pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;

    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
