#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "usage: $0 <repo-root> <hostname> <host-age-recipient> <cli|desktop> <bread-age-recipient>" >&2
  exit 2
fi

repo_root=$1
hostname=$2
recipient=$3
profile=$4
bread_recipient=$5
registry="$repo_root/secrets/recipients.json"

if [[ ! $hostname =~ ^[a-z0-9][a-z0-9-]{0,62}$ ]] || [[ $hostname == *- ]]; then
  echo "invalid hostname: $hostname" >&2
  exit 1
fi

if [[ $recipient != age1* ]] && [[ $recipient != "ssh-ed25519 "* ]]; then
  echo "unsupported age recipient: $recipient" >&2
  exit 1
fi

if [[ $bread_recipient != age1* ]] && [[ $bread_recipient != "ssh-ed25519 "* ]]; then
  echo "unsupported bread age recipient: $bread_recipient" >&2
  exit 1
fi

if [[ $profile != cli && $profile != desktop ]]; then
  echo "profile must be cli or desktop" >&2
  exit 1
fi

existing=$(jq -r --arg hostname "$hostname" '.hosts[$hostname] // empty' "$registry")
if [[ -n $existing && $existing != "$recipient" ]]; then
  echo "recipient mismatch for $hostname" >&2
  echo "registered: $existing" >&2
  echo "provided:   $recipient" >&2
  echo "rotate the host recipient explicitly instead of overwriting it during installation" >&2
  exit 1
fi

existing_bread=$(jq -r '.users.bread // empty' "$registry")
if [[ -n $existing_bread && $existing_bread != "$bread_recipient" ]]; then
  echo "recipient mismatch for shared user bread" >&2
  echo "registered: $existing_bread" >&2
  echo "provided:   $bread_recipient" >&2
  echo "rotate the shared user recipient explicitly instead of overwriting it during installation" >&2
  exit 1
fi

tmp_registry=$(mktemp "${registry}.tmp.XXXXXX")
trap 'rm -f -- "$tmp_registry"' EXIT

jq \
  --arg hostname "$hostname" \
  --arg recipient "$recipient" \
  --arg profile "$profile" \
  --arg bread_recipient "$bread_recipient" \
  '
    .hosts[$hostname] = $recipient
    | .users.bread = $bread_recipient
    | .groups.common = ((.groups.common + [$hostname]) | unique)
    | if $profile == "desktop"
      then .groups.desktop = ((.groups.desktop + [$hostname]) | unique)
      else .
      end
  ' "$registry" > "$tmp_registry"

mv -- "$tmp_registry" "$registry"
trap - EXIT

bash "$repo_root/scripts/render-sops-policy.sh" "$repo_root"
