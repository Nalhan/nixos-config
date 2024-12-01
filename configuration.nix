# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # Set your time zone.
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/Los_Angeles";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
      };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

  # Enable Docker
  virtualisation.docker.enable = true;

  # Install Docker CLI tools, nil, MergerFS, SnapRAID, direnv, and other useful packages
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    nil # Nix Language Server
    mergerfs
    snapraid
    direnv
    git
    curl
    wget
    neovim
    tree
    htop
    nnn
    usbutils
    _1password-cli

  ];

  # Enable direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Set Zsh as the default shell system-wide
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.usbmuxd.enable = false;
}
