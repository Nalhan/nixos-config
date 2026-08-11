{ inputs, pkgs, ... }:
{
  imports = [
    ./niri.nix
    ./audio.nix
  ];

  home-manager = {
    sharedModules = [ inputs.dms.homeModules.dank-material-shell ];
    users.bread.imports = [
      ../../../home/profiles/desktop.nix
    ];
  };

  environment.systemPackages = with pkgs; [
    _1password-cli
    firefox
    kdePackages.dolphin
    kitty
    signal-desktop
    vesktop
    wl-clipboard
  ];

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "bread" ];
    };
  };

  services.udisks2.enable = true;

  users.users.bread.extraGroups = [
    "audio"
    "networkmanager"
  ];
}
