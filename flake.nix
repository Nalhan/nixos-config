{
    description = "My flakes configuration";

    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
      nixvim.url = "github:nix-community/nixvim";
      nixvim.inputs.nixpkgs.follows = "nixpkgs";
      stylix.url = "github:danth/stylix";
      stylix.inputs.nixpkgs.follows = "nixpkgs";
      hyprland.url = "github:hyprwm/Hyprland";
      hyprland-plugins = {
        url = "github:hyprwm/hyprland-plugins";
        inputs.hyprland.follows = "hyprland";
      };
      hyprsplit = {
        url = "github:shezdy/hyprsplit";
        inputs.hyprland.follows = "hyprland";
      };
      clipboard-sync.url = "github:dnut/clipboard-sync";
      clipboard-sync.inputs.nixpkgs.follows = "nixpkgs";
      sops-nix.url = "github:Mic92/sops-nix";
      sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, home-manager, nixvim, nixpkgs, stylix, hyprland, hyprland-plugins, hyprsplit, clipboard-sync, sops-nix}@inputs:
    let
      system = "x86_64-linux";
      specialArgs = inputs // { inherit system; };
      shared-modules = [
        nixvim.nixosModules.nixvim
        stylix.nixosModules.stylix
        clipboard-sync.nixosModules.default
        hyprland.nixosModules.default
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        {
          home-manager = {
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = specialArgs;
            useGlobalPkgs = true;

            sharedModules = [
              nixvim.homeManagerModules.nixvim
              hyprland.homeManagerModules.default
            ];
          };
        }
      ];
    in {
        nixosConfigurations = {
          pergola = nixpkgs.lib.nixosSystem {
            specialArgs = specialArgs;
	    system = system;
            modules = shared-modules ++ [ ./hosts/pergola.nix ];
          };
          breadbox = nixpkgs.lib.nixosSystem {
            specialArgs = specialArgs;
            system = system;
            modules = shared-modules ++ [ ./hosts/breadbox.nix ];
          };
        };

     };
}
