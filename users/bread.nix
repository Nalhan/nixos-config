# users/bread.nix
# defines configuration for this user, can be included on a host config to add the user with all configuration
# this can manage what programs are available and how they are configured

{ pkgs, ...}:

{
  users.users.bread = {
    isNormalUser = true;
    initialPassword = "bread";
    description = "Bread";
    extraGroups = [ "networkmanager" "wheel" "audio"];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    vesktop
    signal-desktop
    plexamp
    grimblast
  ];

  
  home-manager = {
    users.bread = {
      imports = [ 
	../home/home.nix 
	../home/hyprland.nix
      ];
      programs.zsh = {
        enable = true;
      };
      programs.git = {
	enable = true;
	userName = "Nathan Park";
	userEmail = "nalhan.park@gmail.com";
      };
      


      #programs.firefox.enable = true;
      #programs.kitty.enable = true;
      #programs.fuzzel.enable = true;
      #wayland.windowManager.hyprland.enable = true; #enable it here, config is in the home directory
      #programs.plexamp.enable = true;
      #programs._1password.enable = true;
      # programs._1password-gui = {
	# enable = true;
	# polkitPolicyOwners = [ "bread" ];
      # };
      #programs.steam.enable = true;
      #programs.vencord.enable = true;
      #programs.obs_studio.enable = true;
      #programs.signal-desktop.enable = true;
      #programs.vesktop.enable = true;
      home.stateVersion = "24.11";

    };
  };
}

