# Secrets

SOPS encrypts each file to a set of public recipients. Every host has a unique
age identity, users may have a shared identity for user-scoped secrets, and the
admin/recovery recipients can decrypt every managed file. Private identities
and plaintext secrets must never be committed.

## Layout

- `recipients.json` is the public source of truth for admins, users, hosts, and groups.
- `users/<user>.yaml` contains secrets readable anywhere that user's identity is installed.
- `hosts/<hostname>.yaml` contains secrets readable by one host and the admins.
- `common.yaml` may contain secrets readable by every host in `groups.common`.
- `desktop.yaml` may contain secrets readable by hosts in `groups.desktop`.
- `.sops.yaml` is generated from `recipients.json`.

The guided installer reads `op://NixOS/nixos-login/password`, creates
`bread-password-hash` with `mkpasswd`, and encrypts it as the first shared user
secret before the target disk is modified. sops-nix decrypts it early through
`neededForUsers` and supplies it to
`users.users.bread.hashedPasswordFile`.

## Register a host

The installer performs these steps in its private `/etc/nixos` snapshot. To
register a host manually in a Git checkout:

```sh
bash scripts/register-host-recipient.sh \
  "$PWD" vm-01 age1hostexample cli age1breadexample
```

Use `desktop` instead of `cli` for a desktop host. The command refuses to
silently replace an existing host recipient. Key rotation must be explicit so
an unexpected 1Password item cannot remove access to secrets.

After changing group membership or recipients directly, regenerate the policy:

```sh
bash scripts/render-sops-policy.sh "$PWD"
```

Then update the encrypted data-key envelopes for affected files:

```sh
sops updatekeys secrets/hosts/vm-01.yaml
sops updatekeys secrets/users/bread.yaml
sops updatekeys secrets/common.yaml
```

Adding or removing recipients does not expose or manually rewrite the secret
values; SOPS re-encrypts the file's data key for the new recipient set.

## Deployment

Each host receives its private host identity and the shared `bread` identity at
`/var/lib/sops-nix/key.txt` with mode `0600`. At activation, sops-nix decrypts
declared secrets into `/run/secrets` or, for `neededForUsers` secrets,
`/run/secrets-for-users`. Normal boot never depends on network access to
1Password.

The guided installer retrieves or creates the host identity in 1Password and
retrieves the existing `bread-age-key` SSH Key item. Normal rebuilds use the
installed identities and do not authenticate to 1Password.

A service account used for unattended bootstrap must be able to read the
`nixos-login` and `bread-age-key` items. It also needs item-creation permission
when the per-host `<hostname>-age-key` has not been created in advance.

For an already-installed host, retrieve and deploy its native 1Password SSH Key
item with:

```sh
bash scripts/provision-age-key.sh bread@vm-01 vm-01-age-key NixOS
```
