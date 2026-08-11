{ config, lib, ... }:
let
  cfg = config.nalhan.install;
in
{
  options.nalhan.install.bootMode = lib.mkOption {
    type = lib.types.enum [
      "bios"
      "uefi"
    ];
    description = "Firmware boot mode used when installing a generic host.";
  };

  config = lib.mkMerge [
    {
      # Keeping both firmware partitions on every generic installation lets the
      # same disk layout serve BIOS and UEFI machines. Only the selected
      # bootloader is enabled below.
      disko.devices.disk.main = {
        type = "disk";
        device = lib.mkDefault "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            bios = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    }

    (lib.mkIf (cfg.bootMode == "uefi") {
      # The EF02 partition makes Disko configure GRUB automatically. Suppress
      # it for UEFI installations so systemd-boot is the only active loader.
      boot.loader.grub.enable = lib.mkForce false;
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    })

    (lib.mkIf (cfg.bootMode == "bios") {
      # Disko enables GRUB and points it at the selected disk when it sees the
      # EF02 partition. These force-offs prevent an inherited UEFI loader.
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
    })
  ];
}
