# pergola.nix
# machine specific configuration goes here (services, hardware, etc.)

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
      ../configuration.nix
      ../users/pergola.nix
      ../modules/containers/containers.nix
      ../modules/containers/jellyfin.nix
      ../modules/homeassistant/homeassistant.nix
#      ../modules/immich/immich.nix
    ];

  ########
  # Boot #
  ########
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
 
 
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only



  ###############
  # Filesystems #
  ###############
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ac5cec72-5421-4eb8-aa83-2421b6a62de8";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/a7753c5f-d2c5-4cd0-8909-9f0db06930dc"; }
    ];

  ##############
  # Networking #
  ##############
  networking.hostName = "nixos"; # Define your hostname.
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.  
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens18.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
