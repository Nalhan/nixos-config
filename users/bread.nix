{ pkgs, ... }:
{
  # Existing hosts keep their mutable password. Enrolled hosts with
  # secrets/users/bread.yaml receive hashedPasswordFile from sops-nix.
  users.allowNoPasswordLogin = true;

  users.users.bread = {
    isNormalUser = true;
    description = "Nathan Park";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPl1FnQ8PwE7rNoXTYS9O0NZGHGOJIf0/N9W6Y9GTXL7"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPl1FnQ8PwE7rNoXTYS9O0NZGHGOJIf0/N9W6Y9GTXL7"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDINpU/z5TZAT5x2XhGk47KQxhnpCcGkkoqRZ9zerV9E5elZoWtJRd48Q+5hBZT6KwulmR41gBqPOrnW9OGOJsea0gzId3+cb3Z5dXBpSade+zJ5IWt2pKl5rd3kDa7igi9ONM2L8vXayYESJzaFR9w6aCaOjJGasrwgtlCzjd4Ch71x06rrjEfwDEZBZGoe4UvKYudNTavdcwuf8y5iY6arFVmADyLhntVM6tETw9n3At4yPXDtq7f3pXN4bWL3yOvdN8/JEtav/WJdl5OPDM2P56NqDMo0Ktpks3LYXO1+y6skgsIO5W/eZwY9hA9P1f2GQ1Q93URlxm/nvnvLKj7 root@pve"
  ];

  systemd.tmpfiles.rules = [
    "d /home/bread/src 0755 bread users -"
    "Z /home/bread/src/nixos-config 0755 bread users -"
    "L+ /etc/nixos - - - - /home/bread/src/nixos-config"
  ];
}
