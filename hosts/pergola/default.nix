{
  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/roles/cli.nix
    ../../modules/roles/server.nix
    ../../modules/roles/media-server.nix
    ../../modules/roles/home-assistant.nix
    ../../users/bread.nix
    ../../users/pergola-compat.nix
  ];

  networking.hostName = "pergola";
}
