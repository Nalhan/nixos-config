{
  environment.etc."security/sudo-authorized-keys/bread" = {
    mode = "0444";
    text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnahfdjnDMA6GflRFxg7BiruKRic1/P+DwMtCWkZKuR
    '';
  };

  security.pam = {
    sshAgentAuth = {
      enable = true;
      authorizedKeysFiles = [ "/etc/security/sudo-authorized-keys/%u" ];
    };

    services.sudo.sshAgentAuth = true;
  };
}
