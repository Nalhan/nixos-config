{
    description = "My flakes configuration";

    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
      nixvim.url = "github:nix-community/nixvim";
      nixvim.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, home-manager, nixvim, nixpkgs }@inputs:
    let
      system = "x86_64-linux";
      specialArgs = inputs // { inherit system; };
      shared-modules = [
	nixvim.nixosModules.nixvim
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = specialArgs;
            sharedModules = [
              nixvim.homeManagerModules.nixvim
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
        };
     };
}
