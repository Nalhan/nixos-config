# nixos-config

## Setup 
Take a generated hardware-configuration.nix and modify it to import modules as shown in the example pergola.nix. 

Add an entry to flake.nix for the new host.

Build the config with `sudo nixos-rebuild switch --flake /etc/nixos#hostname`, replacing the host config you are building.

