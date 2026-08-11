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
    kdePackages.dolphin
    kitty
    signal-desktop
    vesktop
    wl-clipboard
    inputs.zen-browser.packages.${pkgs.system}.generic
  ];

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "bread" ];
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  services.udisks2.enable = true;

  users.users.bread.extraGroups = [
    "audio"
    "networkmanager"
  ];
}
