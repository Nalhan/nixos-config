# users/home.nix
# home-manager shared settings for all users
{ ... }:

{
  imports = [
    ./nvim/nvim.nix
    #./stylix.nix
  ];

  programs = {

    gh.enable = true; 
  
    eza = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
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
        ls = "eza -al";
      };
    };
  };
  #programs._1password-cli.enable = true;
}
