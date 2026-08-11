{ config, lib, ... }:
let
  userSecretsFile = ../../secrets/users + "/bread.yaml";
  hasUserSecrets = builtins.pathExists userSecretsFile;
in
{
  config = lib.mkIf hasUserSecrets {
    sops = {
      age.keyFile = "/var/lib/sops-nix/key.txt";

      secrets.bread-password-hash = {
        sopsFile = userSecretsFile;
        neededForUsers = true;
      };
    };

    users.allowNoPasswordLogin = lib.mkForce false;
    users.users.bread.hashedPasswordFile = config.sops.secrets.bread-password-hash.path;
  };
}
