# users/home.nix
# home-manager shared settings for all users
{ ... }:

{
  imports = [
    ./nvim/nvim.nix
  ];

  programs.gh.enable = true; 

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "1password" ];
      theme = "robbyrussell";
    };
    shellAliases = {
      ls = "ls -al";
    };
  };

  #programs._1password-cli.enable = true;
}
