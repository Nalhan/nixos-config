{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/var/lib/sops-nix/id_ed25519" ];

    secrets = {
      couchdb_password = {};
    };
  };
}
