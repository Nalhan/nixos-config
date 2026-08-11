{ inputs, lib, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk.nix
    ../../modules/core
    ../../modules/roles/cli.nix
    ../../users/bread.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
  ++ lib.optional (builtins.pathExists ./local-installation.nix) ./local-installation.nix;

  networking = {
    hostName = lib.mkDefault "nixos-cli";
    useDHCP = lib.mkDefault true;
  };

  # Keep the generic initrd able to discover common Proxmox/QEMU SCSI disks
  # before the root filesystem's GPT partition label is resolved.
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
  ];
}
