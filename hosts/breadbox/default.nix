{
  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/roles/cli.nix
    ../../modules/roles/desktop
    ../../modules/hardware/nvidia.nix
    ../../users/bread.nix
  ];

  networking = {
    hostName = "breadbox";
    networkmanager.enable = true;
  };
}
