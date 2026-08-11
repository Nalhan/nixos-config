{
  description = "Reusable NixOS systems and user environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      sops-nix,
      dms,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHost =
        hostModule: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            hostModule
          ] ++ extraModules;
        };

      genericBootOverride = bootMode: {
        config.nalhan.install.bootMode = nixpkgs.lib.mkForce bootMode;
      };

      cliBios = mkHost ./hosts/cli-generic [ ];
      cliUefi = mkHost ./hosts/cli-generic [ (genericBootOverride "uefi") ];
      desktopBios = mkHost ./hosts/desktop-generic [ (genericBootOverride "bios") ];
      desktopUefi = mkHost ./hosts/desktop-generic [ ];

      hasUniversalPartitions =
        configuration:
        let
          partitions = configuration.config.disko.devices.disk.main.content.partitions;
        in
        builtins.all (name: builtins.hasAttr name partitions) [
          "bios"
          "ESP"
          "root"
        ];

      firmwareMatrixValid =
        cliBios.config.boot.loader.grub.enable
        && !cliBios.config.boot.loader.systemd-boot.enable
        && !cliUefi.config.boot.loader.grub.enable
        && cliUefi.config.boot.loader.systemd-boot.enable
        && desktopBios.config.boot.loader.grub.enable
        && !desktopBios.config.boot.loader.systemd-boot.enable
        && !desktopUefi.config.boot.loader.grub.enable
        && desktopUefi.config.boot.loader.systemd-boot.enable
        && builtins.all hasUniversalPartitions [
          cliBios
          cliUefi
          desktopBios
          desktopUefi
        ];

      mkHome =
        {
          desktop ? false,
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            ./home
          ] ++ nixpkgs.lib.optionals desktop [
            ./home/profiles/desktop.nix
            dms.homeModules.dank-material-shell
          ];
        };
    in
    {
      nixosConfigurations = {
        breadbox = mkHost ./hosts/breadbox [ ];
        cli-generic = cliBios;
        desktop-generic = desktopUefi;
        installer = mkHost ./installer [ ];
        pergola = mkHost ./hosts/pergola [ ];
      };

      # Home Manager is intentionally independent from nixos-rebuild so that
      # shell and application configuration can be activated quickly.
      homeConfigurations = {
        "bread@breadbox" = mkHome { desktop = true; };
        "bread@desktop" = mkHome { desktop = true; };
        "bread@cli" = mkHome { };
        "bread@pergola" = mkHome { };
      };

      packages.${system} = {
        disko-install = inputs.disko.packages.${system}.disko-install;
        provision-age-identity = import ./installer/provision-age-identity.nix { inherit pkgs; };
      };

      checks.${system} = {
        firmware-matrix =
          assert firmwareMatrixValid;
          pkgs.runCommand "firmware-matrix-valid" { } ''
            touch $out
          '';

        provision-age-identity =
          pkgs.runCommand "provision-age-identity-test"
            {
              nativeBuildInputs = [ pkgs.jq ];
            }
            ''
              substitute ${./installer/test-provision-age-identity.sh} test-provision-age-identity.sh \
                --replace-fail '@bash@' '${pkgs.bash}/bin/bash'
              bash test-provision-age-identity.sh \
                ${import ./installer/provision-age-identity.nix { inherit pkgs; }}/bin/provision-age-identity
              touch $out
            '';

        sops-recipient-policy =
          pkgs.runCommand "sops-recipient-policy-test"
            {
              nativeBuildInputs = with pkgs; [
                age
                diffutils
                jq
                sops
              ];
            }
            ''
              mkdir -p repo/scripts repo/secrets/hosts repo/secrets/users
              cp ${./scripts/render-sops-policy.sh} repo/scripts/render-sops-policy.sh
              cp ${./scripts/register-host-recipient.sh} repo/scripts/register-host-recipient.sh
              cp ${./secrets/recipients.json} repo/secrets/recipients.json

              bash repo/scripts/render-sops-policy.sh repo
              cmp repo/.sops.yaml ${./.sops.yaml}

              key_file="$PWD/test-age-key.txt"
              age-keygen -o "$key_file" >/dev/null
              recipient=$(age-keygen -y "$key_file")
              user_key_file="$PWD/test-user-age-key.txt"
              age-keygen -o "$user_key_file" >/dev/null
              user_recipient=$(age-keygen -y "$user_key_file")
              bash repo/scripts/register-host-recipient.sh \
                repo test-host "$recipient" cli "$user_recipient"

              jq -e \
                --arg recipient "$recipient" \
                --arg user_recipient "$user_recipient" \
                '.hosts["test-host"] == $recipient
                 and .users.bread == $user_recipient
                 and (.groups.common | index("test-host") != null)
                 and (.groups.desktop | index("test-host") == null)' \
                repo/secrets/recipients.json >/dev/null
              grep -F 'secrets/hosts/test-host' repo/.sops.yaml >/dev/null
              grep -F 'secrets/users/bread' repo/.sops.yaml >/dev/null

              mapfile -t recipients < <(jq -r '.admins[]' repo/secrets/recipients.json)
              recipients+=("$user_recipient")
              recipient_csv=$(IFS=,; printf '%s' "''${recipients[*]}")

              printf '%s\n' 'bread-password-hash: test-password-hash' > plaintext.yaml
              sops --encrypt --age "$recipient_csv" plaintext.yaml > encrypted.yaml
              decrypted=$(SOPS_AGE_KEY_FILE="$user_key_file" \
                sops --decrypt --extract '["bread-password-hash"]' encrypted.yaml)
              test "$decrypted" = 'test-password-hash'

              touch $out
            '';
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
