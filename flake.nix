{
  description = "Powerhouse Flake For NixOS.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
    outputs = { self, nixpkgs, flake-utils, nixvim, nil, ... } @ inputs: let
    systemNix = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit systemNix;
      overlays = [
      ];
   };
  in {
    imports = [ ./nixvim/bufferline.nix ];
    nixosConfigurations.powerhouse = nixpkgs.lib.nixosSystem {
      system = systemNix;
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        self.nixosModules.services.pia-vpn
        nixvim.nixosModules.nixvim {
          programs.nixvim = {
            enable = true;
            viAlias = true;
            vimAlias = true;
            globals.mapleader = " ";  # Set the leader key to space
            clipboard = {
              register = "unnamedplus";  # Use the system clipboard
              providers = {
                wl-copy.enable = true;  # Enable wl-clipboard as the provider
              };
            };
            # Adding Node.js to the environment
            keymaps = [
            {
              key = "<leader>e";
              mode = "n";  # Normal mode
              action = "<cmd>NvimTreeToggle<CR>";  # Toggle nvim-tree
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "<";
              mode = [ "v" "x" ];  # Visual and Visual Line modes
              action = "<gv";
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = ">";
              mode = [ "v" "x" ];  # Visual and Visual Line modes
              action = ">gv";
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "<leader>/";
              mode = "n";  # Normal mode
              action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "<leader>/";
              mode = [ "v" "x" ];  # Visual and Visual Line modes
              action = "<cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
              options = {
                noremap = true;
                silent = true;
              };
            } 
            {
              key = "<leader>f";
              mode = "n";  # Normal mode
              action = "<cmd>lua vim.lsp.buf.format()<CR>";  # Format code
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "<leader>h";
              mode = "n";  # Normal mode
              action = "<cmd>nohlsearch<CR>";  # Clear search highlights
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "y";
              mode = [ "n" "v" ];  # Normal and Visual modes
              action = "\"+y";  # Yank to system clipboard
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "Y";
              mode = "n";  # Normal mode
              action = "\"+Y";  # Yank line to system clipboard
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "p";
              mode = [ "n" "v" ];  # Normal and Visual modes
              action = "\"+p";  # Paste from system clipboard
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "P";
              mode = [ "n" "v" ];  # Normal and Visual modes
              action = "\"+P";  # Paste before from system clipboard
              options = {
                noremap = true;
                silent = true;
              };
            }
            {
              key = "<leader>g";
              mode = "n";  # Normal mode
              action = "<cmd>!lazygit<CR>";  # Open LazyGit
              options = {
                noremap = true;
                silent = true;
              };
            }];
            opts = {
              number = true;          # Enable line numbers
              relativenumber = false; # Disable relative line numbers
              incsearch = true;       # Enable incremental search
              expandtab = true;       # Use spaces instead of tabs
              shiftwidth = 2;         # Number of spaces to use for each step of (auto)indent
              tabstop = 2;            # Number of spaces that a <Tab> in the file counts for
              undofile = true;        # Enable persistent undo
              undodir = "~/.config/nixvim/undo"; # Directory to store undo files
            };
            colorschemes.tokyonight = {
              enable = true;
              settings = {
                day_brightness = 0.3;
                dim_inactive = false;
                hide_inactive_statusline = false;
                light_style = "day";
                lualine_bold = false;
                on_colors = "function(colors) colors.bg = '#000000' end";
                on_highlights = "function(highlights, colors) end";
                sidebars = [
                  "qf"
                  "vista_kind"
                  "terminal"
                  "packer"
                ];
                style = "night";
                styles = {
                  comments = {
                    italic = true;
                  };
                  floats = "dark";
                  functions = { };
                  keywords = {
                    italic = true;
                  };
                  sidebars = "dark";
                  variables = { };
                };
                terminal_colors = true;
                transparent = false;
              };
            };
            plugins = {
              comment = {
                enable = true;
                settings = {
                  opleader = {
                    block = "gb";
                    line = "gc";
                  };
                  toggler = {
                    block = "gbc";
                    line = "gcc";
                  };
                  pre_hook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";
                  ignore = "^const(.*)=(%s?)%((.*)%)(%s?)=>";  # Example ignore pattern
                };
              };
              ts-context-commentstring = {
                enable = true;
              };
              markdown-preview = {
                enable = true;
                settings = {
                  auto_close = true;
                  auto_start = true;
                  browser = "firefox";
                  echo_preview_url = true;
                  highlight_css = {
                    __raw = "vim.fn.expand('~/highlight.css')";
                  };
                  markdown_css = "/Users/username/markdown.css";
                  page_title = "「\${name}」";
                  port = "8080";
                  preview_options = {
                    disable_filename = true;
                    disable_sync_scroll = true;
                    sync_scroll_type = "middle";
                  };
                  theme = "dark";
                };
              };
              lualine.enable = true;
              telescope.enable = true;
              nix.enable = true; # Nix syntax highlighting
              lsp.servers = {
                nil-ls.enable = true;
                pyright.enable = true;
                tailwindcss.enable = true;
                tsserver.enable = true;
              };
              typescript-tools.enable = true;
              ts-autotag = {
                enable = true;
                settings = {
                  opts = {
                    enable_close = true;
                    enable_close_on_slash = false;
                    enable_rename = true;
                  };
                  per_filetype = {
                    html = {
                      enable_close = false;
                    };
                  };
                  alias = {
                    astro = "html";
                    blade = "html";
                    eruby = "html";
                    handlebars = "glimmer";
                    hbs = "glimmer";
                    htmldjango = "html";
                    javascript = "typescriptreact";
                    "javascript.jsx" = "typescriptreact";
                    javascriptreact = "typescriptreact";
                    markdown = "html";
                    php = "html";
                    rescript = "typescriptreact";
                    rust = "rust";
                    twig = "html";
                    typescript = "typescriptreact";
                    "typescript.tsx" = "typescriptreact";
                    vue = "html";
                  };
                };
              };
              treesitter = {
                enable = true;
                nixGrammars = true;
                settings = {
                  auto_install = true;
                  ensure_installed = [
                    "lua"
                    "python"
                    "javascript"
                    "typescript"
                    "html"
                    "css"
                  ];
                  highlight = {
                    additional_vim_regex_highlighting = true;
                    custom_captures = { };
                    disable = [
                      "rust"
                    ];
                    enable = true;
                  };
              ts-context-commentstring = {
                    enable = true;
                    skipTsContextCommentStringModule = true;
                  };
                  ignore_install = [
                    "rust"
                  ];
                  incremental_selection = {
                    enable = true;
                    keymaps = {
                      init_selection = false;
                      node_decremental = "grm";
                      node_incremental = "grn";
                      scope_incremental = "grc";
                    };
                  };
                  indent = {
                    enable = true;
                  };
                  parser_install_dir = {
                    __raw = "vim.fs.joinpath(vim.fn.stdpath('data'), 'treesitter')";
                  };
                  sync_install = false;
                };
              };
              harpoon = {
                enable = true;
                keymaps.addFile = "<leader>a";
              };
              cmp = {
                enable = true;
                autoEnableSources = true;
              };
              cmp-nvim-lsp.enable = true;
              gitsigns.enable = true;
              nvim-tree = {
                enable = true;
                autoReloadOnWrite = true;
                hijackCursor = true;
              };
              nvim-snippets = {
                enable = true;
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
                    "lua"
                  ];
                  search_paths = [
                    {
                      __raw = "vim.fn.stdpath('config') .. '/snippets'";
                    }
                  ];
                };
              };
              # neotest = {
              #  enable = true;
              #  adapters.plenary.enable = true;
              # };
              which-key = {
                enable = true;
                settings = {
                  delay = 200;
                  expand = 1;
                  notify = false;
                  preset = false;
                  replace = {
                    desc = [
                      [
                         "<space>"
                         "SPACE"
                       ]
                       [
                         "<leader>"
                         "SPACE"
                       ]
                       [
                         "<[cC][rR]>"
                         "RETURN"
                       ]
                       [
                         "<[tT][aA][bB]>"
                         "TAB"
                       ]
                       [
                         "<[bB][sS]>"
                         "BACKSPACE"
                       ]
                     ];
                   };
                   spec = [
                     {
                       __unkeyed-1 = "<leader>b";
                      group = "󰓩 Buffers";
                     }
                     {
                       __unkeyed-1 = "<leader>bs";
                       group = "󰒺 Sort";
                     }
                     {
                       __unkeyed-1 = "<leader>g";
                       group = "󰊢 Git";
                     }
                     {
                       __unkeyed-1 = "<leader>f";
                       group = " Format Code";  # Add description for formatting
                     }
                     {
                       __unkeyed-1 = "<leader>r";
                       group = " Refactor";
                     }
                     {
                       __unkeyed-1 = "<leader>t";
                       group = " Terminal";
                     }
                     {
                       __unkeyed-1 = "<leader>u";
                       group = " UI/UX";
                     }
                   ];
                   win = {
                     border = "single";
                   };
                   ignore = {
                     mode = ["v"];  # Ignore visual mode
                     keys = ["v"];  # Ignore the 'v' key specifically
                  };
                };
              };
              # Lazygit
              lazygit = {
                enable = true;
                settings = {
                  config_file_path = [ ];
                  floating_window_border_chars = [
                    "╭"
                    "─"
                    "╮"
                    "│"
                    "╯"
                    "─"
                    "╰"
                    "│"
                  ];
                  floating_window_scaling_factor = 0.9;
                  floating_window_use_plenary = false;
                  floating_window_winblend = 0;
                  use_custom_config_file_path = false;
                  use_neovim_remote = true;
                };
              };
              cursorline = {
                cursorline = {
                  enable = true;
                };
                cursorword = {
                  enable = true;
                };
              };
            };
          };
        }
      ];
    };
    nixosModules = {
      services.pia-vpn = ./modules/pia-vpn.nix;
    };
  };
}
