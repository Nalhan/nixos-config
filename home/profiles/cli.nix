{
  programs = {
    eza = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      settings.user = {
        name = "Nathan Park";
        email = "nalhan.park@gmail.com";
      };
    };

    gh.enable = true;

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
        rebuild = "sudo nixos-rebuild switch --flake ~/src/nixos-config#$(hostname)";
      };
    };
  };
}
