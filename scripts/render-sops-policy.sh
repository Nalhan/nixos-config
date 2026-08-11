#!/usr/bin/env bash
set -euo pipefail

repo_root=${1:-.}
registry="$repo_root/secrets/recipients.json"
policy="$repo_root/.sops.yaml"

if ! command -v jq >/dev/null 2>&1; then
  echo "required command not found: jq" >&2
  exit 1
fi

if ! jq -e '
  (.admins | type == "array" and length > 0)
  and (.hosts | type == "object")
  and (.users | type == "object")
  and (.groups.common | type == "array")
  and (.groups.desktop | type == "array")
  and ([.groups[]?[] as $host | has("hosts") and (.hosts | has($host))] | all)
' "$registry" >/dev/null; then
  echo "invalid SOPS recipient registry: $registry" >&2
  exit 1
fi

tmp_policy=$(mktemp "${policy}.tmp.XXXXXX")
trap 'rm -f -- "$tmp_policy"' EXIT

yaml_string() {
  jq -Rn --arg value "$1" '$value'
}

write_recipients() {
  local recipient
  while IFS= read -r recipient; do
    printf '          - %s\n' "$(yaml_string "$recipient")"
  done
}

recipients_for_host() {
  local host=$1
  jq -r --arg host "$host" '[.admins[], .hosts[$host]] | unique[]' "$registry"
}

recipients_for_user() {
  local user=$1
  jq -r --arg user "$user" '[.admins[], .users[$user]] | unique[]' "$registry"
}

recipients_for_group() {
  local group=$1
  jq -r --arg group "$group" '
    . as $root
    | [$root.admins[], ($root.groups[$group][] as $host | $root.hosts[$host])]
    | unique[]
  ' "$registry"
}

{
  printf '%s\n' '# Generated from secrets/recipients.json; run scripts/render-sops-policy.sh after edits.'
  printf '%s\n' 'creation_rules:'

  while IFS= read -r host; do
    escaped_host=${host//./\\.}
    printf '  - path_regex: %s\n' "$(yaml_string "^secrets/hosts/$escaped_host\\.yaml$")"
    printf '%s\n' '    key_groups:' '      - age:'
    recipients_for_host "$host" | write_recipients
  done < <(jq -r '.hosts | keys[]' "$registry")

  while IFS= read -r user; do
    escaped_user=${user//./\\.}
    printf '  - path_regex: %s\n' "$(yaml_string "^secrets/users/$escaped_user\\.yaml$")"
    printf '%s\n' '    key_groups:' '      - age:'
    recipients_for_user "$user" | write_recipients
  done < <(jq -r '.users | keys[]' "$registry")

  for group in common desktop; do
    printf '  - path_regex: %s\n' "$(yaml_string "^secrets/$group\\.yaml$")"
    printf '%s\n' '    key_groups:' '      - age:'
    recipients_for_group "$group" | write_recipients
  done
} > "$tmp_policy"

mv -- "$tmp_policy" "$policy"
trap - EXIT
