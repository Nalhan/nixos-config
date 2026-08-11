-- Neovim configuration (~/.config/nvim/init.lua)
-- Managed via dotfiles/nvim in nixos-config repository

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8

-- Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>", { desc = "File Explorer" })

-- Nix Language Server (nixd) & Auto-formatting (nixfmt)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = function(ev)
    vim.lsp.start({
      name = "nixd",
      cmd = { "nixd" },
      root_dir = vim.fs.root(ev.buf, { "flake.nix", ".git" }),
      settings = {
        nixd = {
          formatting = {
            command = { "nixfmt" },
          },
          options = {
            nixos = {
              expr = '(builtins.getFlake "' .. (vim.fs.root(ev.buf, { "flake.nix" }) or ".") .. '").nixosConfigurations.cli-generic.options',
            },
          },
        },
      },
    })

    -- LSP Keybindings
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
  end,
})
