{ pkgs, ... }:
{
  # Temporary migration account. Remove after confirming that `bread` can log
  # into pergola and owns any data that should move to /home/bread.
  users.users.pergola = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
  };
}
