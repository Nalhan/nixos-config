# nixos-config

Reusable NixOS host configurations with a consistent CLI baseline and explicit
desktop/server roles.

## Design

- `hosts/` contains hardware facts and selects roles for each machine.
- `modules/core/` is imported by every host.
- `modules/roles/` contains opt-in CLI, desktop, and server capabilities.
- `modules/services/` contains reusable service implementations.
- `users/` describes login identities, not machine roles.
- `home/` is standalone Home Manager, so changing user configuration does not
  require a NixOS rebuild.
- `dotfiles/` contains native, frequently edited application configuration.
- `secrets/` contains encrypted data plus a public per-host recipient registry.

## Hosts

Build and activate a system:

```sh
sudo nixos-rebuild switch --flake .#breadbox
sudo nixos-rebuild switch --flake .#pergola
```

Build without activating:

```sh
nix build .#nixosConfigurations.breadbox.config.system.build.toplevel
```

The `bread` account accepts the declarative administrator SSH login key while
password-based SSH remains disabled. SSH sessions that forward the 1Password
agent can authenticate `sudo` with a separate elevation-only key:

```sh
ssh -A bread@host
sudo command
```

The sudo public key is stored in a root-owned PAM authorization file and is not
accepted for SSH login. Without a forwarded matching agent, sudo falls back to
the account password, preserving console recovery access.

## Home Manager

User environments are intentionally activated separately:

```sh
home-manager switch --flake '.#bread@breadbox'
home-manager switch --flake '.#bread@pergola'
```

The `breadbox` profile includes Niri and DankMaterialShell configuration. The
`pergola` profile contains only the shared CLI experience.

Generic profiles are also available for newly installed machines:

```sh
home-manager switch --flake '.#bread@desktop'
home-manager switch --flake '.#bread@cli'
```

Niri's native KDL file lives at `dotfiles/niri/config.kdl`. Validate it without
rebuilding the operating system:

```sh
niri validate --config dotfiles/niri/config.kdl
```

## Adding a host

1. Create `hosts/<hostname>/default.nix` and `hardware.nix`.
2. Import `modules/core`, `modules/roles/cli.nix`, and only the additional roles
   the host needs.
3. Add the host to `nixosConfigurations` in `flake.nix`.
4. Add a matching Home Manager output if the host needs one.

## Guided installer

The `installer` configuration builds a BIOS/UEFI net-installer ISO containing
every utility needed to partition and install either the shared CLI system or a
generic Niri desktop. The installed system closure is downloaded from the
configured Nix caches during installation.

Build it on an x86_64 NixOS machine:

```sh
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

Locate the ISO beneath `result/iso/`, write it to a USB drive, and boot it in the
firmware mode the installed system should use. At the installer prompt run:

```sh
sudo install-nixos
```

The guided installer:

1. asks whether to install the CLI or Desktop profile;
2. detects BIOS or UEFI from the way the ISO was booted;
3. verifies network access and can open `nmtui`;
4. asks for a hostname and fixed target disk;
5. requires the exact disk path to confirm destructive formatting;
6. generates a filesystem-independent NixOS hardware module;
7. enables the NVIDIA module for Desktop when NVIDIA hardware is detected;
8. authenticates to the `NixOS` 1Password vault once;
9. retrieves or creates the unique `<hostname>-age-key` host identity;
10. retrieves `bread-age-key` and `op://NixOS/nixos-login/password`;
11. hashes the login password and encrypts it for the shared user and admin recipients;
12. registers the public host and user recipients in the installed snapshot;
13. installs the selected generic configuration with Disko; and
14. copies the realized configuration to `/etc/nixos` on the new system.

The live installer enables zstd-compressed zram equal to physical RAM and
limits Nix to one build job with two cores. This keeps net-install evaluation
reliable on 4 GiB VMs without imposing the conservative build limits on the
installed system.

The recommended authentication method is a service-account token scoped to the
NixOS vault. It needs read access and, when a host key does not already exist,
permission to create items. A read-only token is sufficient when the
`<hostname>-age-key` item has been created in advance. The token is pasted
through a hidden prompt and exists only in the installer process. Manual
account setup remains available through `op account add --signin --raw`. Both
methods validate both age identities and read the password before touching the
target disk. The plaintext password exists only in a mode-0600 temporary file,
is hashed immediately, and is deleted before installation begins.

The `bread` password hash is the first user-scoped SOPS secret. It is stored in
`secrets/users/bread.yaml`, encrypted to the shared `bread-age-key` and the
admin/recovery recipients, and decrypted early by sops-nix for account creation.
Every installed host receives its unique host identity and the shared user
identity; normal rebuilds do not require 1Password or network access.

The initial disk layout is intentionally simple:

```text
GPT
|-- BIOS boot  1 MiB, GRUB embedding partition
├── EFI   1 GiB, FAT32, mounted at /boot
└── root  remaining space, ext4, mounted at /
```

Desktop installations use zstd-compressed zram sized to 50% of physical RAM at
priority 100, with an 8 GiB `/swapfile` at priority 10 as a fallback. This does
not provide hibernation support. CLI installations omit the desktop swap policy.

Only non-removable, writable disks are offered by default. The selected disk is
completely erased. Test the ISO in a VM using the intended firmware mode before
using physical hardware.

After reboot and login:

```sh
cd /etc/nixos
home-manager switch --flake '.#bread@cli'      # CLI installation
home-manager switch --flake '.#bread@desktop'  # Desktop installation
```

The generated `hosts/<profile>-generic/hardware-configuration.nix` describes
that machine without duplicating Disko's filesystem declarations. For a
permanent named host, copy the generic host to `hosts/<hostname>`, add it to
`nixosConfigurations`, and commit the generated hardware module.

`/etc/nixos` is a self-contained snapshot embedded in the installer, not a Git
checkout. To contribute the generated host back to this repository, clone the
repository normally and copy `hardware-configuration.nix`,
`local-hardware.nix`, `local-installation.nix`, and the host and user entries
from `secrets/recipients.json` from the installed snapshot before renaming the
host. Copy `secrets/users/bread.yaml` if the repository does not already contain
the current shared password hash. Regenerate `.sops.yaml` afterward.

## Updating inputs

The architecture change replaces the old Hyprland/Stylix/Nixvim inputs with
DankMaterialShell. Regenerate and review the lock file on a Nix machine:

```sh
nix flake lock
nix flake check
```

Commit `flake.nix` and `flake.lock` together after validation.

## Migration notes

- `pergola` is retained temporarily as a compatibility login on the server.
  Confirm that `bread` can log in and migrate any required files before removing
  `users/pergola-compat.nix` from the host.
- Jellyfin now uses the native NixOS service rather than a mutable `latest`
  container. Existing container state under the old bind mount is not imported
  automatically.
- The previous Hyprland, Waybar, SwayNC, Stylix, and generated Nixvim setup was
  removed. It remains recoverable from Git history.
