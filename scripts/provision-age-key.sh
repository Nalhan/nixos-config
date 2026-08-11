#!/usr/bin/env bash
set -euo pipefail
umask 077

if [[ $# -lt 1 || $# -gt 3 ]]; then
  echo "usage: $0 <ssh-target> [1password-item-title] [vault]" >&2
  echo "example: $0 bread@vm-01 vm-01-age-key NixOS" >&2
  exit 2
fi

target=$1
target_host=${target##*@}
item_title=${2:-$target_host-age-key}
vault=${3:-}
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if ! command -v ssh >/dev/null 2>&1; then
  echo "required command not found: ssh" >&2
  exit 1
fi

if command -v provision-age-identity >/dev/null 2>&1; then
  provisioner=(provision-age-identity)
elif command -v nix >/dev/null 2>&1; then
  provisioner=(nix run "$repo_root#provision-age-identity" --)
else
  echo "provision-age-identity or nix is required" >&2
  exit 1
fi

work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
key_file="$work_dir/age-key.txt"

provision_args=(
  --output "$key_file"
  --item "$item_title"
)
if [[ -n $vault ]]; then
  provision_args+=(--vault "$vault")
fi

"${provisioner[@]}" "${provision_args[@]}"

ssh "$target" \
  'sudo install -d -m 0700 /var/lib/sops-nix && sudo tee /var/lib/sops-nix/key.txt >/dev/null && sudo chmod 0600 /var/lib/sops-nix/key.txt' \
  < "$key_file"

echo "provisioned /var/lib/sops-nix/key.txt on $target from 1Password item $item_title"
