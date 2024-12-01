# users/pergola.nix
# define stuff this user needs here
{ pkgs, ... }:

{

  users.users.pergola = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };
  home-manager = {
    users.pergola = {
      imports = [ ../home/home.nix ];
      programs.git = {
        enable = true;
        userName = "Nathan Park";
        userEmail = "nalhan.park@gmail.com";
      };
      home.stateVersion = "23.11";
    };
  };

}
