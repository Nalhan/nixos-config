{ inputs, pkgs }:
let
  diskoInstall = inputs.disko.packages.${pkgs.system}.disko-install;
  provisionAgeIdentity = import ./provision-age-identity.nix { inherit pkgs; };
in
pkgs.writeShellApplication {
  name = "install-nixos";
  runtimeInputs = with pkgs; [
    age
    coreutils
    curl
    findutils
    gnugrep
    gnused
    gum
    jq
    networkmanager
    nixos-install-tools
    openssh
    pciutils
    provisionAgeIdentity
    sops
    util-linux
    whois
    inputs.disko.packages.${pkgs.system}.disko-install
  ];
  text = ''
    if [[ $EUID -ne 0 ]]; then
      echo "install-nixos must run as root; use: sudo install-nixos" >&2
      exit 1
    fi

    profile=$(gum choose \
      --header "Choose the system profile to install" \
      "CLI" \
      "Desktop")

    case "$profile" in
      CLI)
        host_configuration="cli-generic"
        home_configuration="bread@cli"
        profile_summary="Shared CLI environment"
        ;;
      Desktop)
        host_configuration="desktop-generic"
        home_configuration="bread@desktop"
        profile_summary="Niri + DankMaterialShell + shared CLI environment"
        ;;
      *)
        gum style --foreground 196 "Unknown installation profile: $profile"
        exit 1
        ;;
    esac

    if [[ -d /sys/firmware/efi ]]; then
      boot_mode="uefi"
      boot_summary="UEFI with systemd-boot"
    else
      boot_mode="bios"
      boot_summary="Legacy BIOS with GRUB"
    fi

    gum style \
      --border rounded \
      --padding "1 2" \
      --foreground 212 \
      "NixOS guided installer" \
      "$profile_summary" \
      "$boot_summary"

    while ! curl --fail --silent --show-error --max-time 10 \
      https://cache.nixos.org/nix-cache-info >/dev/null; do
      gum style --foreground 214 "A network connection is required."
      if gum confirm "Open NetworkManager now?"; then
        nmtui
      else
        echo "Installation cancelled."
        exit 1
      fi
    done

    hostname=$(gum input \
      --prompt "Hostname: " \
      --placeholder "workstation" \
      --value "workstation")

    if [[ ! $hostname =~ ^[a-z0-9][a-z0-9-]{0,62}$ ]] || [[ $hostname == *- ]]; then
      gum style --foreground 196 \
        "Invalid hostname. Use lowercase letters, numbers, and internal hyphens."
      exit 1
    fi

    mapfile -t disks < <(
      lsblk --json --output PATH,TYPE,RM,RO \
        | jq -r '.blockdevices[] | select(.type == "disk" and .rm == false and .ro == false) | .path'
    )

    if [[ ''${#disks[@]} -eq 0 ]]; then
      gum style --foreground 196 "No eligible fixed disks were found."
      exit 1
    fi

    choices=()
    for disk in "''${disks[@]}"; do
      disk_size=$(lsblk --nodeps --noheadings --raw --output SIZE "$disk" | sed 's/[[:space:]]*$//')
      disk_model=$(lsblk --nodeps --noheadings --raw --output MODEL "$disk" | sed 's/[[:space:]]*$//')
      choices+=("$disk | $disk_size | $disk_model")
    done

    selection=$(printf '%s\n' "''${choices[@]}" \
      | gum choose --header "Select the disk to erase and install NixOS onto")
    target_disk=''${selection%% |*}

    if [[ -z $target_disk || ! -b $target_disk ]]; then
      gum style --foreground 196 "The selected disk is not a valid block device."
      exit 1
    fi

    gum style --foreground 196 --bold \
      "ALL DATA ON $target_disk WILL BE PERMANENTLY ERASED."
    confirmation=$(gum input --prompt "Type $target_disk to continue: ")
    if [[ $confirmation != "$target_disk" ]]; then
      echo "Disk confirmation did not match; installation cancelled."
      exit 1
    fi

    work_dir=$(mktemp -d)
    secret_dir=$(mktemp -d)
    trap 'rm -rf "$work_dir" "$secret_dir"' EXIT
    chmod 700 "$secret_dir"

    cp -a ${inputs.self}/. "$work_dir/"
    chmod -R u+w "$work_dir"

    gum style --foreground 212 "Detecting hardware..."
    nixos-generate-config \
      --no-filesystems \
      --show-hardware-config \
      > "$work_dir/hosts/$host_configuration/hardware-configuration.nix"

    if [[ $profile == "Desktop" ]] && lspci -nn | grep -Eiq '(VGA|3D).*NVIDIA'; then
      printf '%s\n' \
        '{ imports = [ ../../modules/hardware/nvidia.nix ]; }' \
        > "$work_dir/hosts/desktop-generic/local-hardware.nix"
      gpu_summary="NVIDIA proprietary driver enabled"
    elif [[ $profile == "Desktop" ]]; then
      gpu_summary="GPU configuration supplied by NixOS Facter"
    else
      gpu_summary="Desktop GPU configuration not requested"
    fi

    printf '%s\n' \
      '{' \
      "  networking.hostName = \"$hostname\";" \
      "  nalhan.install.bootMode = \"$boot_mode\";" \
      "  disko.devices.disk.main.device = \"$target_disk\";" \
      '}' \
      > "$work_dir/hosts/$host_configuration/local-installation.nix"

    host_age_key="$secret_dir/host-age-key.txt"
    bread_age_key="$secret_dir/bread-age-key.txt"
    bread_password="$secret_dir/bread-password"
    if ! provision-age-identity \
      --output "$host_age_key" \
      --item "$hostname-age-key" \
      --additional-output "$bread_age_key" \
      --additional-item "bread-age-key" \
      --additional-reference "op://NixOS/bread-age-key/private key?ssh-format=openssh" \
      --secret-output "$bread_password" \
      --secret-reference "op://NixOS/nixos-login/password" \
      --vault "NixOS"; then
      gum style --foreground 196 \
        "Installation cancelled. The target disk has not been modified."
      exit 1
    fi
    identity_summary="host and bread age identities are backed by 1Password"

    password_hash_file="$secret_dir/bread-password-hash"
    mkpasswd --method=yescrypt --stdin < "$bread_password" > "$password_hash_file"
    chmod 600 "$password_hash_file"
    rm -f -- "$bread_password"

    host_recipient=$(age-keygen -y "$host_age_key")
    bread_recipient=$(age-keygen -y "$bread_age_key")
    profile_slug=$(printf '%s' "$profile" | tr '[:upper:]' '[:lower:]')

    if ! bash "$work_dir/scripts/register-host-recipient.sh" \
      "$work_dir" "$hostname" "$host_recipient" "$profile_slug" "$bread_recipient"; then
      gum style --foreground 196 \
        "The host recipient could not be registered in the installed configuration."
      echo "Installation cancelled. The target disk has not been modified."
      exit 1
    fi

    mapfile -t secret_recipients < <(
      jq -r '.admins[]' "$work_dir/secrets/recipients.json"
    )
    secret_recipients+=("$bread_recipient")
    recipient_csv=$(IFS=,; printf '%s' "''${secret_recipients[*]}")

    plaintext_secrets="$secret_dir/user-secrets.yaml"
    jq -n \
      --arg password_hash "$(<"$password_hash_file")" \
      '{"bread-password-hash": $password_hash}' \
      > "$plaintext_secrets"
    chmod 600 "$plaintext_secrets"

    install -d "$work_dir/secrets/users"
    if ! sops --encrypt \
      --input-type yaml \
      --output-type yaml \
      --age "$recipient_csv" \
      "$plaintext_secrets" \
      > "$work_dir/secrets/users/bread.yaml"; then
      rm -f -- "$work_dir/secrets/users/bread.yaml"
      gum style --foreground 196 "Failed to encrypt the account password."
      echo "Installation cancelled. The target disk has not been modified."
      exit 1
    fi
    chmod 644 "$work_dir/secrets/users/bread.yaml"
    rm -f -- "$password_hash_file" "$plaintext_secrets"

    installed_age_keys="$secret_dir/installed-age-keys.txt"
    {
      cat "$host_age_key"
      printf '\n'
      cat "$bread_age_key"
      printf '\n'
    } > "$installed_age_keys"
    chmod 600 "$installed_age_keys"

    extra_args=(
      --extra-files "$work_dir" /home/bread/src/nixos-config
      --extra-files "$installed_age_keys" /var/lib/sops-nix/key.txt
    )

    secrets_summary="bread password encrypted for admin/recovery and the shared bread identity"

    gum style \
      --border rounded \
      --padding "1 2" \
      "Hostname: $hostname" \
      "Profile: $profile" \
      "Boot mode: $boot_summary" \
      "Target disk: $target_disk" \
      "$gpu_summary" \
      "$identity_summary" \
      "$secrets_summary" \
      "Filesystem: GPT + BIOS boot + 1 GiB EFI + ext4 root"

    if ! gum confirm "Erase $target_disk and install now?"; then
      echo "Installation cancelled."
      exit 1
    fi

    install_args=(
      --mode format
      --flake "$work_dir#$host_configuration"
      --disk main "$target_disk"
    )
    if [[ $boot_mode == "uefi" ]]; then
      install_args+=(--write-efi-boot-entries)
    fi
    install_args+=("''${extra_args[@]}")

    ${diskoInstall}/bin/disko-install "''${install_args[@]}"

    if [[ -d /mnt/home/bread/src/nixos-config ]]; then
      chown -R 1000:100 /mnt/home/bread
      mkdir -p /mnt/etc
      ln -sfn /home/bread/src/nixos-config /mnt/etc/nixos
    fi

    gum style \
      --border double \
      --padding "1 2" \
      --foreground 82 \
      "Installation completed successfully." \
      "User environment (zsh, dotfiles, profile) was configured during install." \
      "Repo location: ~/src/nixos-config (/etc/nixos -> ~/src/nixos-config)" \
      "System rebuild: sudo nixos-rebuild switch --flake ~/src/nixos-config#$host_configuration" \
      "Home rebuild:   home-manager switch --flake ~/src/nixos-config#$home_configuration"
  '';
}
