# users/home.nix
# home-manager shared settings for all users
{ ... }:

{
  imports = [
    ./nvim.nix
  ];

#packages
#  programs.neovim = {
#    enable = true;
#    viAlias = true;
#    vimAlias = true;
#    plugins = with pkgs.vimPlugins; [
#      nvim-lspconfig
#      vim-nix
#      luasnip
#      nvim-cmp
#      cmp_luasnip
#      cmp-nvim-lsp
#      fidget-nvim
#      nvim-treesitter.withAllGrammars
#      plenary-nvim
#      nightfox-nvim
#      auto-session
#      mini-nvim
#    ];
#    extraConfig = ''        
#        luafile ${./nvim.lua}
#        set number
#        set tabstop=2
#        set shiftwidth=2
#        set expandtab
#   '';
#  };
  
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
}
