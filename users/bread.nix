# users/bread.nix
# defines configuration for this user, can be included on a host config to add the user with all configuration
# this can manage what programs are available and how they are configured

{ pkgs, ...}:

{
  users.users.bread = {
    isNormalUser = true;
    initialPassword = "bread";
    description = "Bread";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    };
  home-manager = {
    users.bread = {
      imports = [ ../home/home.nix ];
      programs.zsh = {
        enable = true;
      };
      programs.git = {
	enable = true;
	userName = "Nathan Park";
	userEmail = "nalhan.park@gmail.com";
      };
      programs.firefox.enable = true;
      programs.kitty.enable = true;
      home.stateVersion = "24.11";
    };
  };
}

