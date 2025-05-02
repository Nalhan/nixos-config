{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "~/.ssh/id_ed25519" ];

    secrets = {
      couchdb_password = {};
    };
  };
}
