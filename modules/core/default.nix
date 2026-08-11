{ lib, ... }:
{
  imports = [
    ./nix.nix
    ./networking.nix
    ./secrets.nix
    ./ssh.nix
    ./sudo.nix
  ];

  services.qemuGuest.enable = lib.mkDefault true;

  time.timeZone = "America/Los_Angeles";
  system.stateVersion = "24.05";
}
