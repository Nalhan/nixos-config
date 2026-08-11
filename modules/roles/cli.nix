{ inputs, pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
    };
    users.bread.imports = [
      ../../home
    ];
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    bat
    bottom
    eza
    fd
    fzf
    htop
    jq
    neovim
    nnn
    ripgrep
    tmux
    tree
    unzip
    wget
  ] ++ [ inputs.home-manager.packages.${pkgs.system}.home-manager ];
}
