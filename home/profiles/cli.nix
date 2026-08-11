{ pkgs, ... }:
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

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withRuby = false;
      withPython3 = false;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "1password"
        ];
        theme = "robbyrussell";
      };
      shellAliases = {
        ls = "eza -al";
        rebuild = "sudo nixos-rebuild switch --flake ~/src/nixos-config#$(hostname)";
      };
    };
  };

  # Symlink dotfiles/nvim to ~/.config/nvim so your Lua configuration
  # can be edited live or managed as a submodule for non-Nix hosts.
  xdg.configFile."nvim".source = ../../dotfiles/nvim;

  home.sessionPath = [
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"
  ];

  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    nodejs
  ];
}
