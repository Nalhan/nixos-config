# nvidia.nix
{ config, lib, pkgs, ... }:

{
   
  services.xserver = {
    #enable = true;  # Leave enabling xserver to the window manager configuration
    videoDrivers = ["nvidia"]; # but we can still make sure it's set to use nvidia drivers
  };
  
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    nvidiaSettings = true;
    
    # we're using the beta version here. could override this in the host's config 
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "570.86.16";
      sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
      openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
      settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
      usePersistenced = false;
    };
  };
}
