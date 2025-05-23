{ self, pkgs, ... }: {

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    #colorschemes.oxocarbon.enable = true;
    imports = [
      ./keymaps.nix
    ];
    
    globalOpts = {
      number = true;
      relativenumber = true;
      signcolumn = "yes";
      splitright = true;
      splitbelow = true;
    
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 0;
      expandtab = true;
      smarttab = true;
      
      list = true;
      # NOTE: .__raw here means that this field is raw lua code
      listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";
    
      # Save undo history
      undofile = true;

      # Highlight the current line for cursor
      cursorline = true;

      # Show line and column when searching
      ruler = true;

      # Global substitution by default
      gdefault = true;

      # Start scrolling when the cursor is X lines away from the top/bottom
      scrolloff = 5;
    };

    plugins = {
      # Navigate Tmux with the same keybindings as Neovim
      tmux-navigator = {
        enable = true;
        keymaps = [
          {
            action = "left";
            key = "<C-w>h";
          }
          {
            action = "down";
            key = "<C-w>j";
          }
          {
            action = "up";
            key = "<C-w>k";
          }
          {
            action = "right";
            key = "<C-w>l";
          }
          {
            action = "previous";
            key = "<C-w>\\";
          }
        ];
      };

      # Buffer bar
      bufferline = {
        enable = true;
      };

      # Status bar
      lualine = {
        enable = true;
      };

      # Make `nvim .` look prettier
      oil = {
        enable = true;
      };

      neoscroll = {
        enable = true;
      };

      # Includes all parsers for treesitter
      treesitter = {
        enable = true;
      };

      # Icons 
      web-devicons.enable = true;

      sleuth = {
        enable = true;
      };

      # Auto-tagging
      ts-autotag = {
        enable = true;
      };

      # Autopairs
      nvim-autopairs = {
        enable = true;
      };

#      none-ls = {
#        enable = true;
#        settings = {
#          cmd = ["bash -c nvim"];
#          debug = true;
#        };
#        sources = {
#          code_actions = {
#            statix.enable = true;
#            gitsigns.enable = true;
#          };
#          diagnostics = {
#            statix.enable = true;
#            deadnix.enable = true;
#            pylint.enable = true;
#            checkstyle.enable = true;
#          };
#          formatting = {
#            alejandra.enable = true;
#            stylua.enable = true;
#            shfmt.enable = true;
#            nixpkgs_fmt.enable = true;
#            google_java_format.enable = false;
#            prettier = {
#              enable = true;
#              disableTsServerFormatter = true;
#            };
#            black = {
#              enable = true;
#              settings = ''
#                {
#                  extra_args = { "--fast" },
#                }
#              '';
#
#            };
#          };
#          completion = {
#            luasnip.enable = true;
#            spell.enable = true;
#          };
#        };
#      };

      # Lazygit
      lazygit = {
        enable = true;
      };

      # Notify
      notify = {
        enable = true;
        settings = {
          backgroundColour = "#1e1e2e";
          fps = 60;
          render = "default";
          timeout = 500;
          topDown = true;
        };
      };

      # Persistence
      persistence.enable = true;

      # Debugger
      dap = {
        enable = true;
        signs = {
          dapBreakpoint = {
            text = "●";
            texthl = "DapBreakpoint";
          };
          dapBreakpointCondition = {
            text = "●";
            texthl = "DapBreakpointCondition";
          };
          dapLogPoint = {
            text = "◆";
            texthl = "DapLogPoint";
          };
        };
        
        configurations = {
          java = [
            {
              type = "java";
              request = "launch";
              name = "Debug (Attach) - Remote";
              hostName = "127.0.0.1";
              port = 5005;
            }
          ];
        };
      };

      dap-python.enable = true;
      #dap-ui = {
        # enable = true;
        # floating.mappings = {
          # close = ["<ESC>" "q"];
        # };
      # };
      dap-virtual-text.enable = true;



      # Linting
      lint = {
        enable = true;
        lintersByFt = {
          text = ["vale"];
          json = ["jsonlint"];
          markdown = ["vale"];
          rst = ["vale"];
          ruby = ["ruby"];
          janet = ["janet"];
          inko = ["inko"];
          clojure = ["clj-kondo"];
          dockerfile = ["hadolint"];
          terraform = ["tflint"];
        };
      };

      # Trouble
      trouble = {
        enable = true;
      };

      # Friendly Snippets 
      friendly-snippets = {
        enable = true;
      };


      # Easily toggle comments
      commentary.enable = true;

      # Terminal inside Neovim
      toggleterm = {
        enable = true;
        settings = {
          hide_numbers = false;
          autochdir = true;
          close_on_exit = true;
          direction = "vertical";
        };
      };

      # Git signs in code
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
      };

      which-key = {
        enable = false;
        registrations = {
          "<leader>fg" = "Find Git files with telescope";
          "<leader>fw" = "Find text with telescope";
          "<leader>ff" = "Find files with telescope";
        };
      };

      # Markdown preview server
      markdown-preview = {
        enable = true;
        settings.theme = "dark";
      };

      render-markdown = {
        enable = true;
        settings = {
          enabled = true; # This lets you set whether the plugin should render documents from the start or not. Useful if you want to use a command like RenderMarkdown enable to start rendering documents rather than having it on by default.
          bullet = {
            icons = [
              "•"
            ];
            right_pad = 1;
          };
          code = {
            above = " ";
            below = " ";
            border = "thick";
            language_pad = 2;
            left_pad = 2;
            position = "right";
            right_pad = 2;
            sign = false;
            width = "block";      
          };
          heading = {
            border = true;
            icons = [
              "1 "
              "2 "
              "3 "
              "4 "
              "5 "
              "6 "
            ];
            position = "inline";
            sign = false;
            width = "full";
          };
          render_modes = true;
          signs = {
            enabled = false;
          };
        };
      };

      image = {
        enable = true;
        settings = {
          backend = "kitty";
          hijackFilePatterns = [
            "*.png"
            "*.jpg"
            "*.jpeg"
            "*.gif"
            "*.webp"
          ];
          maxHeightWindowPercentage = 25;
          tmuxShowOnlyInActiveWindow = true;
          settings.integrations = {
            markdown = {
              enabled = true;
              downloadRemoteImages = true;
              filetypes = [
                "markdown"
                "vimwiki"
                "mdx"
              ];
            };
          };
        };
      };

      # Prettier fancier command window
      noice = {
        enable = true;
      };

      # Good old Telescope
      telescope = {
        enable = true;
        extensions = {
          fzf-native = {
            enable = true;
          };
        };
      };

      # Todo comments
      todo-comments = {
        enable = true;
        settings.colors = {
          error = ["DiagnosticError" "ErrorMsg" "#DC2626"];
          warning = ["DiagnosticWarn" "WarningMsg" "#FBBF24"];
          info = ["DiagnosticInfo" "#2563EB"];
          hint = ["DiagnosticHint" "#10B981"];
          default = ["Identifier" "#7C3AED"];
          test = ["Identifier" "#FF00FF"];
        };
      };

      # File tree
      neo-tree = {
        enable = true;
        enableDiagnostics = true;
        enableGitStatus = true;
        enableModifiedMarkers = true;
        enableRefreshOnWrite = true;
        closeIfLastWindow = true;
        popupBorderStyle = "rounded"; # Type: null or one of “NC”, “double”, “none”, “rounded”, “shadow”, “single”, “solid” or raw lua code
        buffers = {
          bindToCwd = false;
          followCurrentFile = {
            enabled = true;
          };
        };
        window = {
          width = 40;
          height = 15;
          autoExpandWidth = false;
          mappings = {
            "<space>" = "none";
          };
        };
      };

      undotree = {
        enable = true;
        settings = {
          autoOpenDiff = true;
          focusOnToggle = true;
        };
      };

      # Highlight word under cursor
      illuminate = {
        enable = true;
        underCursor = false;
        filetypesDenylist = [
          "Outline"
          "TelescopePrompt"
          "alpha"
          "harpoon"
          "reason"
        ];
      };

      hardtime = {
        enable = false;
        settings = {
          disableMouse = true;
          enabled = false;
          disabledFiletypes = [ "Oil" ];
          restrictionMode = "hint";
          hint = true;
          maxCount = 40;
          maxTime = 1000;
          restrictedKeys = {
            "h" = [ "n" "x" ];
            "j" = [ "n" "x" ];
            "k" = [ "n" "x" ];
            "l" = [ "n" "x" ];
            "-" = [ "n" "x" ];
            "+" = [ "n" "x" ];
            "gj" = [ "n" "x" ];
            "gk" = [ "n" "x" ];
            "<CR>" = [ "n" "x" ];
            "<C-M>" = [ "n" "x" ];
            "<C-N>" = [ "n" "x" ];
            "<C-P>" = [ "n" "x" ];
          };
        };
      };

      # Nix expressions in Neovim
      nix = {
        enable = true;
      };

      # Language server
      lsp = {
        enable = true;
        servers = {
          # Average webdev LSPs
          # ts-ls.enable = true; # TS/JS
          ts_ls.enable = true; # TS/JS
          cssls.enable = true; # CSS
          tailwindcss.enable = true; # TailwindCSS
          html.enable = true; # HTML
          astro.enable = true; # AstroJS
          phpactor.enable = true; # PHP
          svelte.enable = false; # Svelte
          vuels.enable = false; # Vue
          pyright.enable = true; # Python
          marksman.enable = true; # Markdown
          nixd = {
            # Nix LS
            enable = true;
            settings =
            let
                flake = ''(builtins.getFlake "${self}")'';
            in
            {
              nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
              options = rec {
                nixos.expr = "${flake}.nixosConfigurations.breadbox.options";
                home-manager.expr = "${nixos.expr}.home-manager.users.type.getSubOptions [ ]";
                nixvim.expr = ''(${nixos.expr}.home-manager.users.type.getSubOptions []).programs.nixvim.type.getSubOptions ["programs" "nixvim" ]'';
              };
              eval = {
                depth = 15;
                workers = 4;
              };
              formatting = {
                command = ["nixpkgs-fmt"];
              };
            };
          };

          dockerls.enable = true; # Docker
          bashls.enable = true; # Bash
          clangd.enable = true; # C/C++
          csharp_ls.enable = true; # C#
          yamlls.enable = true; # YAML
          ltex = {
            enable = true;
            settings = {
              enabled = [ "astro" "html" "latex" "markdown" "text" "tex" "gitcommit" ];
              completionEnabled = true;
              language = "en-US";
            };
          };
          gopls = { # Golang
            enable = true;
            autostart = true;
          };

          lua_ls = { # Lua
            enable = true;
            settings.telemetry.enable = false;
          };

          # Rust
          rust_analyzer = {
            enable = true;
            installRustc = true;
            installCargo = true;
          };
        };
      };

      wtf = {
        enable = true;
        context = true;
        popupType = "popup";
        openaiApiKey = "boop"; # TODO: add API key
        openaiModelId = "gpt-3.5-turbo";
        searchEngine = "duck_duck_go"; # | "google" | "stack_overflow" | "github" | "phind" | "perplexity";
        # hooks.requestFinished = ""; # TODO: add notification here 
      };

      # Dashboard
      alpha = {
        enable = true;
        theme = "dashboard";
        # iconsEnabled = true; # Deprecated
      };

      # Even more snippets
      nvim-snippets = {
        enable = false;
        settings = {
          create_autocmd = true;
          create_cmp_source = true;
          extended_filetypes = {
            typescript = [
              "javascript"
            ];
          };
          friendly_snippets = true;
          global_snippets = [
            "all"
          ];
          ignored_filetypes = [
          #  "lua"
          ];
          search_paths = [
            {
              __raw = "vim.fn.stdpath('config') .. '/snippets'";
            }
          ];
        };
      };

      cmp-emoji = {
        enable = true;
      };

      cmp = {
        enable = true;
        settings = {
          completion = {
            completeopt = "menu,menuone,noinsert";
          };
          autoEnableSources = true;
          experimental = { ghost_text = true; };
          performance = {
            debounce = 60;
            fetchingTimeout = 200;
            maxViewEntries = 30;
          };
          snippet = { 
            expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
          };
          formatting = { fields = [ "kind" "abbr" "menu" ]; };
          sources = [
            { name = "nvim_lsp"; }
            { name = "emoji"; }
            {
              name = "buffer"; # text within current buffer
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              keywordLength = 3;
            }
            # { name = "copilot"; } # enable/disable copilot
            {
              name = "path"; # file system paths
              keywordLength = 3;
            }
            {
              name = "luasnip"; # snippets
              keywordLength = 3;
            }
          ];

          window = {
            completion = { border = "solid"; };
            documentation = { border = "solid"; };
          };

          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-e>" = "cmp.mapping.abort()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
            "<C-l>" = ''
              cmp.mapping(function()
                if luasnip.expand_or_locally_jumpable() then
                  luasnip.expand_or_jump()
                end
              end, { 'i', 's' })
            '';
            "<C-h>" = ''
              cmp.mapping(function()
                if luasnip.locally_jumpable(-1) then
                  luasnip.jump(-1)
                end
              end, { 'i', 's' })
            '';
          };
        };
      };
      cmp-nvim-lsp = {
        enable = true; # LSP
      };
      cmp-buffer = {
        enable = true;
      };
      cmp-path = {
        enable = true; # file system paths
      };
      cmp_luasnip = {
        enable = true; # snippets
      };
      cmp-cmdline = {
        enable = true; # autocomplete for cmdline
      }; 

      lspkind = {
        enable = true;
        symbolMap = {
          Copilot = "";
        };
        extraOptions = {
          maxwidth = 50;
          ellipsis_char = "...";
        };
      };

      schemastore = {
        enable = true;
        yaml.enable = true;
        json.enable = false;
      };

      fidget = {
        enable = true;
        settings = {
          logger = {
            level = "warn"; # “off”, “error”, “warn”, “info”, “debug”, “trace”
            floatPrecision = 0.01; # Limit the number of decimals displayed for floats
          };
          progress = {
            pollRate = 0; # How and when to poll for progress messages
            suppressOnInsert = true; # Suppress new messages while in insert mode
            ignoreDoneAlready = false; # Ignore new tasks that are already complete
            ignoreEmptyMessage = false; # Ignore new tasks that don't contain a message
            clearOnDetach =
              # Clear notification group when LSP server detaches
              ''
                function(client_id)
                  local client = vim.lsp.get_client_by_id(client_id)
                  return client and client.name or nil
                end
              '';
            notificationGroup =
              # How to get a progress message's notification group key
              ''
                function(msg) return msg.lsp_client.name end
              '';
            ignore = [ ]; # List of LSP servers to ignore
            lsp = {
              progressRingbufSize = 0; # Configure the nvim's LSP progress ring buffer size
            };
            display = {
              renderLimit = 16; # How many LSP messages to show at once
              doneTtl = 3; # How long a message should persist after completion
              doneIcon = "✔"; # Icon shown when all LSP progress tasks are complete
              doneStyle = "Constant"; # Highlight group for completed LSP tasks
              progressTtl = "math.huge"; # How long a message should persist when in progress
              progressIcon = {
                pattern = "dots";
                period = 1;
              }; # Icon shown when LSP progress tasks are in progress
              progressStyle = "WarningMsg"; # Highlight group for in-progress LSP tasks
              groupStyle = "Title"; # Highlight group for group name (LSP server name)
              iconStyle = "Question"; # Highlight group for group icons
              priority = 30; # Ordering priority for LSP notification group
              skipHistory = true; # Whether progress notifications should be omitted from history
              formatMessage = ''
                require ("fidget.progress.display").default_format_message
              ''; # How to format a progress message
              formatAnnote = ''
                function (msg) return msg.title end
              ''; # How to format a progress annotation
              formatGroupName = ''
                function (group) return tostring (group) end
              ''; # How to format a progress notification group's name
              overrides = {
                rust_analyzer = {
                  name = "rust-analyzer";
                };
              }; # Override options from the default notification config
            };
          };
          notification = {
            pollRate = 10; # How frequently to update and render notifications
            filter = "info"; # “off”, “error”, “warn”, “info”, “debug”, “trace”
            historySize = 128; # Number of removed messages to retain in history
            overrideVimNotify = true;
            # redirect = ''
              # function(msg, level, opts)
                # if opts and opts.on_open then
                  # return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
                # end
              # end
            # '';
            # configs = {
              # default = ''require('fidget.notification').default_config'';
            # };

            window = {
              normalHl = "Comment";
              winblend = 0;
              border = "none"; # none, single, double, rounded, solid, shadow
              zindex = 45;
              maxWidth = 0;
              maxHeight = 0;
              xPadding = 1;
              yPadding = 0;
              align = "bottom";
              relative = "editor";
            };
            view = {
              stackUpwards = true; # Display notification items from bottom to top
              iconSeparator = " "; # Separator between group name and icon
              groupSeparator = "---"; # Separator between notification groups
              groupSeparatorHl =
                # Highlight group used for group separator
                "Comment";
          };
        };
      };
    };

  };

  extraConfigVim = ''
  '';

  extraConfigLuaPre = ''
    if vim.g.have_nerd_font then
      require('nvim-web-devicons').setup {}
    end
  '';

  extraConfigLuaPost = ''
    -- vim: ts=2 sts=2 sw=2 et
  '';

  extraConfigLua = ''
    require("telescope").load_extension("lazygit")

    luasnip = require("luasnip")
    kind_icons = {
      Text = "󰊄",
      Method = "",
      Function = "󰡱",
      Constructor = "",
      Field = "",
      Variable = "󱀍",
      Class = "",
      Interface = "",
      Module = "󰕳",
      Property = "",
      Unit = "",
      Value = "",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "",
      Event = "",
      Operator = "",
      TypeParameter = "",
    } 

    local cmp = require'cmp'

    -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({'/', "?" }, {
      sources = {
        { name = 'buffer' }
      }
    })

    -- Set configuration for specific filetype.
     cmp.setup.filetype('gitcommit', {
       sources = cmp.config.sources({
         { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
       }, {
         { name = 'buffer' },
       })
     })

     -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
     cmp.setup.cmdline(':', {
       sources = cmp.config.sources({
         { name = 'path' }
       }, {
         { name = 'cmdline' }
       }),
  --      formatting = {
  --       format = function(_, vim_item)
  --         vim_item.kind = cmdIcons[vim_item.kind] or "FOO"
  --       return vim_item
  --      end
  -- }
       })  '';



  extraPlugins = with pkgs.vimPlugins;
    [
      vim-be-good
      glow-nvim # Glow inside of Neovim
      clipboard-image-nvim
    ];
    #    ++ [
    #      (pkgs.vimUtils.buildVimPlugin {
    #      pname = "markview.nvim";
    #      version = "0.0.1";
    #      src = pkgs.fetchFromGitHub {
    #        owner = "OXY2DEV";
    #        repo = "markview.nvim";
    #        rev = "a959d77ca7e9f05175e3ee4e582db40b338c9164";
    #        hash = "sha256-w6yn8aNcJMLRbzaRuj3gj4x2J/20wUROLM6j39wpZek=";
    #      };
    #    })
    #      # Just copy this block for a new plugin
    #      # (pkgs.vimUtils.buildVimPlugin {
    #      #   pname = "";
    #      #   src = pkgs.fetchFromGitHub {
    #      #     owner = "";
    #      #     repo = "";
    #      #     rev = "";
    #      #     sha256 = "";
    #      #   };
    #      # })
    #    ];

  };
}

