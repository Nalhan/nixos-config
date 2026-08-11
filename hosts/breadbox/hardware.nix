{ config, lib, pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "module_blacklist=amdgpu" ];
    supportedFilesystems = [ "ntfs" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a72e9744-2e74-4771-84da-99531ff5db6d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/2C09-3BC6";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
    "/mnt/gigadisk" = {
      device = "/dev/disk/by-uuid/22E600A86FE85315";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" ];
    };
    "/mnt/linuxgigadisk" = {
      device = "/dev/disk/by-uuid/ea107b30-3d7d-47fc-bcbf-32d26c4e6dc2";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/f5a93d61-9fa1-4128-9c56-6fafa080afde"; }
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
