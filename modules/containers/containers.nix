{ config, pkgs, ... }:
{
  config.virtualisation.oci-containers = {
    backend = "docker";
  };
}
