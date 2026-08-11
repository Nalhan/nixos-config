#!/usr/bin/env bash
set -euo pipefail

provision=${1:?path to provision-age-identity is required}
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

mock_dir="$test_root/bin"
mkdir -p "$mock_dir"

cat > "$mock_dir/op" <<'EOF'
#!@bash@
set -euo pipefail

if [[ ${1:-} == read \
  && ${2:-} == "op://NixOS/bread-age-key/private key?ssh-format=openssh" ]]; then
  printf '%s\r\n' \
    '-----BEGIN OPENSSH PRIVATE KEY-----' \
    'mock-private-key' \
    '-----END OPENSSH PRIVATE KEY-----'
  exit 0
fi

case "${1:-} ${2:-}" in
  "whoami ")
    exit 0
    ;;
  "vault get")
    printf '%s\n' '{"id":"vault-id","name":"Test Vault"}'
    ;;
  "item list")
    if [[ $TEST_MODE == bundle ]]; then
      printf '%s\n' '[{"id":"item-id","title":"test-age-key"},{"id":"bread-item-id","title":"bread-age-key"}]'
    elif [[ $TEST_MODE == existing || $TEST_MODE == placeholder || -e $TEST_STATE/created ]]; then
      printf '%s\n' '[{"id":"item-id","title":"test-age-key"}]'
    else
      printf '%s\n' '[]'
    fi
    ;;
  "item get")
    if [[ " $* " == *" --reveal "* ]]; then
      if [[ $TEST_MODE == placeholder && ! -e $TEST_STATE/created ]]; then
        printf '%s\n' \
          '{"id":"item-id","title":"test-age-key","category":"SECURE_NOTE","fields":[]}'
      else
        if [[ $TEST_MODE == existing || $TEST_MODE == bundle ]]; then
          key_value='-----BEGIN OPENSSH PRIVATE KEY-----\nmock-private-key\n-----END OPENSSH PRIVATE KEY-----'
        else
          key_value='-----BEGIN PRIVATE KEY-----\nmock-pkcs8-private-key\n-----END PRIVATE KEY-----'
        fi
        printf '%s\n' \
          "{\"id\":\"item-id\",\"title\":\"test-age-key\",\"category\":\"SSH_KEY\",\"fields\":[{\"id\":\"private_key\",\"label\":\"private key\",\"value\":\"$key_value\"}]}"
      fi
    elif [[ $TEST_MODE == placeholder && ! -e $TEST_STATE/archived ]]; then
      printf '%s\n' \
        '{"id":"item-id","title":"test-age-key","category":"SECURE_NOTE"}'
    else
      printf '%s\n' \
        '{"id":"item-id","title":"test-age-key","category":"SSH_KEY"}'
    fi
    ;;
  "item delete")
    if [[ " $* " != *" --archive "* ]]; then
      echo "Mock placeholder replacement must archive the old item." >&2
      exit 1
    fi
    touch "$TEST_STATE/archived"
    ;;
  "item create")
    if [[ " $* " != *" --category SSH Key "* \
      || " $* " != *" --ssh-generate-key=ed25519 "* \
      || " $* " != *" --title test-age-key "* ]]; then
      echo "Mock item creation requires native Ed25519 SSH Key flags." >&2
      exit 1
    fi
    touch "$TEST_STATE/created"
    printf '%s\n' \
      '{"id":"item-id","title":"test-age-key","category":"SSH_KEY"}'
    ;;
  "read --no-newline")
    if [[ ${3:-} != "op://NixOS/nixos-login/password" ]]; then
      echo "Unexpected mock secret reference: ${3:-}" >&2
      exit 1
    fi
    printf '%s' 'test-login-password'
    ;;
  *)
    printf 'Unexpected mock op invocation:' >&2
    printf ' <%s>' "$@" >&2
    printf '\n' >&2
    exit 1
    ;;
esac
EOF

cat > "$mock_dir/gum" <<'EOF'
#!@bash@
set -euo pipefail
case "${1:-}" in
  style) exit 0 ;;
  confirm) exit 0 ;;
  *) echo "Unexpected mock gum invocation: $*" >&2; exit 1 ;;
esac
EOF

cat > "$mock_dir/ssh-to-age" <<'EOF'
#!@bash@
set -euo pipefail
if [[ ${1:-} != -private-key || ${2:-} != -i || ! -f ${3:-} ]]; then
  echo "Unexpected mock ssh-to-age invocation: $*" >&2
  exit 1
fi
grep -q '^-----BEGIN OPENSSH PRIVATE KEY-----$' "$3"
printf '%s\n' 'AGE-SECRET-KEY-1DERIVED'
EOF

cat > "$mock_dir/ssh-keygen" <<'EOF'
#!@bash@
set -euo pipefail
key_file=""
while [[ $# -gt 0 ]]; do
  if [[ $1 == -f ]]; then
    key_file=$2
    break
  fi
  shift
done
if [[ -z $key_file ]] || ! grep -q '^-----BEGIN PRIVATE KEY-----$' "$key_file"; then
  echo "Unexpected mock ssh-keygen invocation." >&2
  exit 1
fi
printf '%s\n' \
  '-----BEGIN OPENSSH PRIVATE KEY-----' \
  'normalized-private-key' \
  '-----END OPENSSH PRIVATE KEY-----' \
  > "$key_file"
touch "$TEST_STATE/normalized"
EOF
chmod +x \
  "$mock_dir/op" "$mock_dir/gum" "$mock_dir/ssh-keygen" "$mock_dir/ssh-to-age"

for mode in existing create placeholder; do
  state_dir="$test_root/$mode-state"
  output="$test_root/$mode-key.txt"
  mkdir -p "$state_dir"

  TEST_MODE=$mode \
  TEST_STATE=$state_dir \
  OP_BIN="$mock_dir/op" \
  GUM_BIN="$mock_dir/gum" \
  SSH_KEYGEN_BIN="$mock_dir/ssh-keygen" \
  SSH_TO_AGE_BIN="$mock_dir/ssh-to-age" \
    "$provision" \
      --output "$output" \
      --vault "Test Vault" \
      --item test-age-key \
      --yes

  grep -q '^AGE-SECRET-KEY-1' "$output"
done

test -e "$test_root/create-state/created"
test -e "$test_root/placeholder-state/archived"
test -e "$test_root/placeholder-state/created"
test -e "$test_root/create-state/normalized"
test -e "$test_root/placeholder-state/normalized"
grep -q '^AGE-SECRET-KEY-1DERIVED$' "$test_root/create-key.txt"

bundle_state="$test_root/bundle-state"
mkdir -p "$bundle_state"
TEST_MODE=bundle \
TEST_STATE=$bundle_state \
OP_BIN="$mock_dir/op" \
GUM_BIN="$mock_dir/gum" \
SSH_KEYGEN_BIN="$mock_dir/ssh-keygen" \
SSH_TO_AGE_BIN="$mock_dir/ssh-to-age" \
  "$provision" \
    --output "$test_root/bundle-host-key.txt" \
    --item test-age-key \
    --additional-output "$test_root/bundle-user-key.txt" \
    --additional-item bread-age-key \
    --additional-reference "op://NixOS/bread-age-key/private key?ssh-format=openssh" \
    --secret-output "$test_root/bundle-password.txt" \
    --secret-reference "op://NixOS/nixos-login/password" \
    --vault "Test Vault" \
    --yes

grep -q '^AGE-SECRET-KEY-1DERIVED$' "$test_root/bundle-host-key.txt"
grep -q '^AGE-SECRET-KEY-1DERIVED$' "$test_root/bundle-user-key.txt"
test "$(<"$test_root/bundle-password.txt")" = 'test-login-password'
