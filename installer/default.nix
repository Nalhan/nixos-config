{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  guidedInstaller = import ./guided-installer.nix {
    inherit inputs pkgs;
  };
  provisionAgeIdentity = import ./provision-age-identity.nix { inherit pkgs; };
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ../modules/core
  ];

  networking = {
    hostName = "nixos-guided-installer";
    networkmanager.enable = true;
    wireless.enable = lib.mkForce false;
  };

  # Nix evaluation and target closure realization can exceed the free memory
  # of small installer VMs. Keep the live environment reliable without
  # carrying this conservative build policy into installed hosts.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 100;
  };
  boot.kernel.sysctl."vm.swappiness" = 100;

  nix.settings = {
    max-jobs = lib.mkForce 1;
    cores = lib.mkForce 2;
  };

  # The installer is an ephemeral, LAN-scoped environment. Allow its standard
  # live user to accept the well-known installer password without weakening
  # SSH policy on any installed host.
  services.openssh.settings = {
    PasswordAuthentication = lib.mkForce true;
    KbdInteractiveAuthentication = lib.mkForce true;
    PermitRootLogin = lib.mkForce "no";
  };
  users.users.nixos = {
    initialHashedPassword = lib.mkForce null;
    initialPassword = lib.mkForce "nixos";
  };

  environment.systemPackages = with pkgs; [
    guidedInstaller
    inputs.disko.packages.${pkgs.system}.disko-install
    _1password-cli
    curl
    git
    gum
    jq
    networkmanager
    nixos-install-tools
    pciutils
    provisionAgeIdentity
    util-linux
    whois
  ];

  programs.bash.interactiveShellInit = ''
    if [[ $EUID -ne 0 && -z ''${NIXOS_INSTALLER_HINT_SHOWN:-} ]]; then
      export NIXOS_INSTALLER_HINT_SHOWN=1
      echo
      echo "Run 'sudo install-nixos' to start the guided NixOS installer."
      echo
    fi
  '';
}
