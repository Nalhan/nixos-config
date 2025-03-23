# hosts/breadbox.nix
# this describes system specific configuration for the machine.
# to make a new one - install nixos normally and generate a hardware-configuration.nix as a starting point.

{ config, lib, pkgs, modulesPath, ... }:

{

  boot.kernelPackages=pkgs.linuxPackages_latest;
  
  imports =
    [ 
      #(modulesPath + "/installer/scan/not-detected.nix"),
      ../configuration.nix
      ../modules/nvidia.nix
      ../modules/hyprland.nix
      ../users/bread.nix
    ];
  
  ########
  # BOOT #
  ########

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # use latest kernel
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages=pkgs.linuxPackagesFor (pkgs.linux_6_11.override {
  #  argsOverride = rec {
  #    src = pkgs.fetchurl {
  #     url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
  #	sha256 = "sha256-C/XsZEgX15KJIPdjWBMR9b8lipJ1nPLzCYXadDrz67I=";
  #    };
  #    version = "6.11.7";
  #    modDirVersion = "6.11.7";
  #    };
  #});
  
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "module_blacklist=amdgpu" ];
  
  ###############
  # FILESYSTEMS #
  ###############

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a72e9744-2e74-4771-84da-99531ff5db6d";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2C09-3BC6";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/f5a93d61-9fa1-4128-9c56-6fafa080afde";
    }
  ];

  ##############
  # NETWORKING #
  ##############
  
  networking.hostName = "breadbox";
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp9s0.useDHCP = lib.mkDefault true;

  ########
  # MISC #
  ########

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  


  #########
  # SOUND #
  #########

  #sound.enable = true;
  #hardware.pulseaudio = {
  #   enable = true;
  #  support32Bit = true;
  #};

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  ############
  # PROGRAMS #
  ############

  programs.steam.enable = true;
  # programs.vencord.enable = true;
  # programs.plexamp.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "bread" ];
  };
  #programs.obs-studio.enable = true;
  #programs.vesktop.enable = true;
}
