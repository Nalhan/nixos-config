#!/usr/bin/env bash
set -euo pipefail
umask 077

op_bin="${OP_BIN:-op}"
gum_bin="${GUM_BIN:-gum}"
jq_bin="${JQ_BIN:-jq}"
ssh_keygen_bin="${SSH_KEYGEN_BIN:-ssh-keygen}"
ssh_to_age_bin="${SSH_TO_AGE_BIN:-ssh-to-age}"

output=""
item_title="$(hostname)-age-key"
additional_output=""
additional_item_title=""
additional_reference=""
secret_output=""
secret_reference=""
vault=""
assume_yes=false
onepassword_session_token=""
onepassword_auth_args=()

usage() {
  cat <<'EOF'
Usage: provision-age-identity --output PATH [--item TITLE] [OPTIONS]

Read an Ed25519 SSH key from a native 1Password SSH Key item and convert it to
an age identity. If the item does not exist, optionally ask 1Password to create
and populate the SSH Key item before converting its private key.

Options:
  --additional-output PATH  Also provision a second age identity.
  --additional-item TITLE   SSH Key item for the second identity.
  --additional-reference REF
                            Exact op:// private-key reference for the second identity.
  --secret-output PATH      Read a 1Password field into this mode-0600 file.
  --secret-reference REF    op:// reference paired with --secret-output.
  --vault VAULT             Vault containing the SSH Key item(s).
  --yes                     Create missing SSH Key items without confirmation.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      output=${2:?--output requires a path}
      shift 2
      ;;
    --item)
      item_title=${2:?--item requires a title}
      shift 2
      ;;
    --additional-output)
      additional_output=${2:?--additional-output requires a path}
      shift 2
      ;;
    --additional-item)
      additional_item_title=${2:?--additional-item requires a title}
      shift 2
      ;;
    --additional-reference)
      additional_reference=${2:?--additional-reference requires an op:// reference}
      shift 2
      ;;
    --secret-output)
      secret_output=${2:?--secret-output requires a path}
      shift 2
      ;;
    --secret-reference)
      secret_reference=${2:?--secret-reference requires an op:// reference}
      shift 2
      ;;
    --vault)
      vault=${2:?--vault requires a vault name or ID}
      shift 2
      ;;
    --yes)
      assume_yes=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z $output ]]; then
  echo "--output is required" >&2
  exit 2
fi

if [[ -n $additional_output || -n $additional_item_title ]]; then
  if [[ -z $additional_output || -z $additional_item_title ]]; then
    echo "--additional-output and --additional-item must be used together" >&2
    exit 2
  fi
fi

if [[ -n $additional_reference && -z $additional_output ]]; then
  echo "--additional-reference requires --additional-output" >&2
  exit 2
fi

if [[ -n $secret_output || -n $secret_reference ]]; then
  if [[ -z $secret_output || -z $secret_reference ]]; then
    echo "--secret-output and --secret-reference must be used together" >&2
    exit 2
  fi
fi

for command_path in \
  "$op_bin" "$gum_bin" "$jq_bin" "$ssh_keygen_bin" "$ssh_to_age_bin"; do
  if ! command -v "$command_path" >/dev/null 2>&1; then
    echo "Required command is unavailable: $command_path" >&2
    exit 1
  fi
done

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
chmod 700 "$work_dir"

run_op() {
  # Global authentication flags must precede subcommands whose positional
  # arguments include '-', otherwise the session flag can be parsed as an
  # item-field assignment instead of a global option.
  "$op_bin" "${onepassword_auth_args[@]}" "$@"
}

convert_private_key_to_age() {
  local private_key_file=$1
  local age_key_file=$2
  local normalized_private_key="$work_dir/normalized-private-key.txt"
  local line_normalized_private_key

  # Keys created in the 1Password desktop app can be exported with CRLF line
  # endings, while CLI-generated items are normally LF-only. A literal CR at
  # the end of PEM/OpenSSH header lines prevents key parsers from recognizing
  # them, so normalize the temporary export before inspecting or converting it.
  line_normalized_private_key=$(mktemp "$work_dir/private-key-lf.XXXXXX")
  tr -d '\r' < "$private_key_file" > "$line_normalized_private_key"
  chmod 600 "$line_normalized_private_key"
  private_key_file=$line_normalized_private_key

  if grep -q '^AGE-SECRET-KEY-1' "$private_key_file"; then
    install -m 600 "$private_key_file" "$age_key_file"
  else
    if "$ssh_to_age_bin" -private-key -i "$private_key_file" \
      > "$age_key_file" 2>/dev/null; then
      chmod 600 "$age_key_file"
    else
      # 1Password currently exports generated Ed25519 keys as PKCS#8. The
      # pinned ssh-to-age release parses that as ed25519.PrivateKey but only
      # accepts *ed25519.PrivateKey. Re-encoding a temporary copy as OpenSSH
      # normalizes the Go type without changing the underlying key material.
      install -m 600 "$private_key_file" "$normalized_private_key"
      if ! "$ssh_keygen_bin" -q -p -P "" -N "" \
        -f "$normalized_private_key" >/dev/null 2>&1 \
        || ! "$ssh_to_age_bin" -private-key -i "$normalized_private_key" \
          > "$age_key_file"; then
        rm -f -- "$normalized_private_key" "$age_key_file"
        return 1
      fi
      rm -f -- "$normalized_private_key"
      chmod 600 "$age_key_file"
    fi

    if [[ ! -s $age_key_file ]]; then
      rm -f -- "$age_key_file"
      return 1
    fi
  fi

  grep -q '^AGE-SECRET-KEY-1' "$age_key_file"
}

read_item_private_key() {
  local item_id=$1
  local vault_id=$2
  local private_key_file=$3
  local revealed_item="$work_dir/revealed-item.json"

  if ! run_op item get "$item_id" \
    --vault "$vault_id" \
    --reveal \
    --format=json \
    > "$revealed_item"; then
    return 1
  fi

  # Prefer the native SSH Key field ID/label, then fall back to any private-key
  # PEM value. This avoids relying on display labels in an op:// reference.
  # shellcheck disable=SC2016 # jq field expressions are not shell variables.
  if ! "$jq_bin" -er '
      [
        .fields[]?
        | select((.value? | type) == "string")
        | select(
            (.id? == "private_key")
            or (((.label? // "") | ascii_downcase) == "private key")
            or (.value | contains("PRIVATE KEY"))
          )
        | .value
      ]
      | first
    ' "$revealed_item" > "$private_key_file"; then
    rm -f -- "$private_key_file"
    return 1
  fi
  chmod 600 "$private_key_file"
}

sign_in_manually() {
  local session_token

  if ! "$op_bin" account list --format=json \
    | "$jq_bin" -e 'length > 0' >/dev/null 2>&1; then
    "$gum_bin" style --foreground 214 \
      "No 1Password account is configured in this live environment."
    "$gum_bin" style \
      "Add it with your sign-in address, email, Secret Key, and password."
    if ! session_token=$("$op_bin" account add --signin --raw); then
      return 1
    fi
  elif ! session_token=$("$op_bin" signin --raw); then
    return 1
  fi

  if [[ -z $session_token ]]; then
    return 1
  fi

  onepassword_session_token=$session_token
  onepassword_auth_args=(--session "$onepassword_session_token")
  unset session_token
  run_op whoami >/dev/null 2>&1
}

use_service_account() {
  local raw_token service_account_token err_output

  raw_token=$("$gum_bin" input \
    --password \
    --char-limit 0 \
    --prompt "Paste service-account token: ")
  service_account_token=$(printf '%s' "$raw_token" | tr -d '\r\n[:space:]')
  if [[ -z $service_account_token ]]; then
    return 1
  fi

  export OP_SERVICE_ACCOUNT_TOKEN=$service_account_token
  unset raw_token service_account_token

  err_output=$(mktemp)
  if ! run_op whoami >"$err_output" 2>&1 && ! run_op vault list >"$err_output" 2>&1; then
    "$gum_bin" style --foreground 196 "1Password error output:"
    cat "$err_output" >&2
    rm -f "$err_output"
    return 1
  fi
  rm -f "$err_output"
  return 0
}

if ! run_op whoami >/dev/null 2>&1; then
  "$gum_bin" style --foreground 214 "1Password authentication is required."
  authentication_method=$("$gum_bin" choose \
    --header "Choose a 1Password authentication method" \
    "Service-account token (recommended)" \
    "Manual account sign-in")

  case "$authentication_method" in
    "Service-account token (recommended)")
      until use_service_account; do
        unset OP_SERVICE_ACCOUNT_TOKEN
        "$gum_bin" style --foreground 196 "Service-account authentication failed."
        if ! "$gum_bin" confirm "Retry with another service-account token?"; then
          exit 1
        fi
      done
      ;;
    "Manual account sign-in")
      until sign_in_manually; do
        "$gum_bin" style --foreground 196 "1Password sign-in failed."
        if ! "$gum_bin" confirm "Retry 1Password authentication?"; then
          exit 1
        fi
      done
      ;;
    *)
      echo "Unknown 1Password authentication method." >&2
      exit 1
      ;;
  esac
fi

vault_json="$work_dir/vault.json"
if [[ -n $vault ]]; then
  if ! run_op vault get "$vault" --format=json > "$vault_json"; then
    echo "The requested 1Password vault is not accessible: $vault" >&2
    exit 1
  fi
else
  vaults_json="$work_dir/vaults.json"
  if ! run_op vault list --format=json > "$vaults_json"; then
    echo "Could not list accessible 1Password vaults." >&2
    exit 1
  fi

  mapfile -t vault_names < <("$jq_bin" -r '.[].name' "$vaults_json")
  if [[ ${#vault_names[@]} -eq 0 ]]; then
    echo "The authenticated account has no readable vaults." >&2
    exit 1
  elif [[ ${#vault_names[@]} -eq 1 ]]; then
    vault=${vault_names[0]}
  else
    vault=$(printf '%s\n' "${vault_names[@]}" \
      | "$gum_bin" choose --header "Choose the vault for the NixOS age identity")
  fi

  # shellcheck disable=SC2016 # $name is a jq variable.
  "$jq_bin" --arg name "$vault" \
    '.[] | select(.name == $name)' "$vaults_json" > "$vault_json"
fi

vault_id=$("$jq_bin" -er '.id' "$vault_json")
vault_name=$("$jq_bin" -er '.name' "$vault_json")
identity_index=0

provision_identity() {
  local requested_item_title=$1
  local requested_output=$2
  local candidate_key private_key items_json item_json item_id item_category
  local -a matching_item_ids

  identity_index=$((identity_index + 1))
  candidate_key="$work_dir/candidate-age-key-$identity_index.txt"
  private_key="$work_dir/private-key-$identity_index.txt"

  while true; do
    if [[ -z $requested_item_title ]]; then
      requested_item_title=$("$gum_bin" input --prompt "1Password item title: ")
    fi

    items_json="$work_dir/items-$identity_index.json"
    item_json="$work_dir/item-$identity_index.json"
    if ! run_op item list --vault "$vault_id" --format=json > "$items_json"; then
      echo "Could not list items in '$vault_name'; refusing to assume the key is absent." >&2
      return 1
    fi

    # shellcheck disable=SC2016 # $title is a jq variable.
    mapfile -t matching_item_ids < <(
      "$jq_bin" -r --arg title "$requested_item_title" \
        '.[] | select(.title == $title) | .id' "$items_json"
    )

    if [[ ${#matching_item_ids[@]} -gt 1 ]]; then
      "$gum_bin" style --foreground 196 \
        "More than one item is named '$requested_item_title'; use a unique item title."
      if ! "$gum_bin" confirm "Choose a different item title?"; then
        return 1
      fi
      requested_item_title=""
      continue
    elif [[ ${#matching_item_ids[@]} -eq 1 ]]; then
      item_id=${matching_item_ids[0]}
      if ! run_op item get "$item_id" --vault "$vault_id" --format=json \
        > "$item_json"; then
        echo "The age identity item '$vault_name/$requested_item_title' was listed but could not be read." >&2
        return 1
      fi
      item_category=$("$jq_bin" -r '.category // ""' "$item_json")
      if read_item_private_key "$item_id" "$vault_id" "$private_key" \
        && convert_private_key_to_age "$private_key" "$candidate_key"; then
        install -m 600 "$candidate_key" "$requested_output"
        "$gum_bin" style --foreground 82 \
          "Loaded and converted the existing identity from $vault_name/$requested_item_title."
        break
      fi

      "$gum_bin" style --foreground 196 \
        "The item '$vault_name/$requested_item_title' exists but its 'private key' field is missing or invalid."

      if [[ $item_category == "SECURE_NOTE" ]] \
        && "$gum_bin" confirm \
          "Archive this invalid Secure Note and replace it with a native SSH Key item?"; then
        if ! run_op item delete "$item_id" --vault "$vault_id" --archive; then
          echo "Could not archive the invalid Secure Note." >&2
          return 1
        fi
        "$gum_bin" style --foreground 214 \
          "Archived the invalid Secure Note; creating its SSH Key replacement."
      else
        if ! "$gum_bin" confirm "Choose a different item title?"; then
          return 1
        fi
        requested_item_title=""
        continue
      fi
    fi

    if [[ $assume_yes != true ]] \
      && ! "$gum_bin" confirm \
        "Create a native Ed25519 SSH Key item named '$requested_item_title' in '$vault_name'?"; then
      return 1
    fi

    if ! run_op item create \
      --category "SSH Key" \
      --ssh-generate-key=ed25519 \
      --title "$requested_item_title" \
      --vault "$vault_id" \
      --format=json \
      > "$item_json"; then
      echo "Could not create the native SSH Key item in 1Password." >&2
      echo "Confirm that this account has permission to create items in '$vault_name'." >&2
      return 1
    fi

    item_id=$("$jq_bin" -er '.id' "$item_json")
    if ! read_item_private_key "$item_id" "$vault_id" "$private_key" \
      || ! convert_private_key_to_age "$private_key" "$candidate_key"; then
      echo "The SSH Key item was created, but its private key could not be read and converted." >&2
      echo "Item: $vault_name/$requested_item_title" >&2
      echo "Check read permission for '$vault_name', then rerun this command." >&2
      return 1
    fi

    install -m 600 "$candidate_key" "$requested_output"
    "$gum_bin" style --foreground 82 \
      "Created $vault_name/$requested_item_title and verified its derived age identity."
    break
  done
}

provision_identity_reference() {
  local reference=$1
  local requested_output=$2
  local private_key candidate_key

  identity_index=$((identity_index + 1))
  private_key="$work_dir/reference-private-key-$identity_index.txt"
  candidate_key="$work_dir/reference-age-key-$identity_index.txt"

  if ! run_op read "$reference" > "$private_key"; then
    rm -f -- "$private_key"
    return 1
  fi
  chmod 600 "$private_key"

  if ! convert_private_key_to_age "$private_key" "$candidate_key"; then
    rm -f -- "$private_key" "$candidate_key"
    return 1
  fi

  install -m 600 "$candidate_key" "$requested_output"
  "$gum_bin" style --foreground 82 \
    "Loaded and converted the shared identity from its 1Password reference."
}

provision_identity "$item_title" "$output"

if [[ -n $additional_output ]]; then
  if [[ -n $additional_reference ]]; then
    if ! provision_identity_reference "$additional_reference" "$additional_output"; then
      "$gum_bin" style --foreground 214 \
        "The shared-key reference could not be read; checking whether its item must be created."
      provision_identity "$additional_item_title" "$additional_output"
    fi
  else
    provision_identity "$additional_item_title" "$additional_output"
  fi
fi

if [[ -n $secret_output ]]; then
  if ! run_op read --no-newline "$secret_reference" > "$secret_output"; then
    rm -f -- "$secret_output"
    echo "Could not read the requested 1Password secret: $secret_reference" >&2
    exit 1
  fi
  if [[ ! -s $secret_output ]]; then
    rm -f -- "$secret_output"
    echo "The requested 1Password secret is empty: $secret_reference" >&2
    exit 1
  fi
  chmod 600 "$secret_output"
fi

unset onepassword_session_token OP_SERVICE_ACCOUNT_TOKEN
onepassword_auth_args=()
