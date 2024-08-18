{
    description = "Powerhouse Flake For NixOS.";

    inputs = {
      # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";  # This defaults to the master branch
      nixpkgs.url = "path:/home/kixadmin/.dotfiles/patches/nixpkgs";
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
      overlays = [ ];
   };
   in {
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
              # path = "/home/kixadmin/.config/nixvim/init.lua";
              diagnostics = {
                virtual_lines = {
                  only_current_line = true;
                };
                virtual_text = false;
              };
              globals.mapleader = " ";  # Set the leader key to space
              clipboard = {
                register = "unnamedplus";  # Use the system clipboard
                providers = {
                  wl-copy.enable = true;  # Enable wl-clipboard as the provider
                };
              };

              # Adding Node.js to the environment
              keymaps = [{
              key = "K";
              mode = "n"; # Normal mode
              action = "i<CR><Esc>"; # Insert newline at cursor position
              options = {
                noremap = true;
                silent = true;
                desc = "Split line at cursor";
                  };
              }
              {
                key = "<leader>w";
                mode = "n";  # Normal mode
                action = "<cmd>w<CR>";  # Write (save) the current buffer
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Save current buffer";
                };
              }
              {
                key = "<leader>q";
                mode = "n";  # Normal mode
                action = "<cmd>q<CR>";  # Quit the current buffer
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Quit current buffer";
                };
              }
              {
                key = ">";
                mode = "n"; # Normal mode
                action = ">>"; # Indent line
                options = {
                  noremap = true;
                  silent = true;
                  desc = "which_key_ignore"; # This will not show in which-key
                };
              }
              {
                key = "<";
                mode = "n"; # Normal mode
                action = "<<"; # Unindent line
                options = {
                  noremap = true;
                  silent = true;
                  desc = "which_key_ignore"; # This will not show in which-key
                };
              }
              {
                key = "<leader>bc";
                mode = "n"; # Normal mode
                action = "<cmd>bd<CR>"; # Close current buffer
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Close current buffer";
                };
              }
              {
                key = "<leader>bn";
                mode = "n"; # Normal mode
                action = "<cmd>bnext<CR>"; # Go to next buffer
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Go to next buffer";
                };
              }
              {
                key = "<leader>bb";
                mode = "n"; # Normal mode
                action = "<cmd>bprevious<CR>"; # Go to previous buffer
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Go to previous buffer";
                };
              }
              {
                key = "<leader>b";
                mode = "n"; # Normal mode
                action = "<cmd>ls<CR>:b<Space>"; # List buffers and wait for input
                options = {
                  noremap = true;
                  silent = false; # Allow user to see the buffer list
                  desc = "Buffer";
                };
              }
              {
                key = "<C-l>";
                mode = "n"; # Normal mode
                action = "<C-w>l"; # Move to right pane
                options = {
                  noremap = true;
                  silent = true;
                };
              }
              {
                key = "<C-h>";
                mode = "n"; # Normal mode
                action = "<C-w>h"; # Move to left pane
                options = {
                  noremap = true;
                  silent = true;
                };
              }
              {
                key = "<leader>e";
                mode = "n";  # Normal mode
                action = "<cmd>NvimTreeToggle<CR>";  # Toggle nvim-tree
                options = {
                  noremap = true;
                  silent = true;
                  desc = "File explorer";
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
                mode = "n"; # Normal mode
                action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Comment/uncomment line.";
                };
              }
              {
                key = "<leader>/";
                mode = [ "v" "x" ]; # Visual and Visual-Block modes
                action = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Comment/uncomment selected lines.";
                };
              }
              {
                key = "<leader>f";
                mode = "n";  # Normal mode
                action = "<cmd>lua vim.lsp.buf.format()<CR>";  # Format code
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Format code";
                };
              }
              {
                key = "<leader>h";
                mode = "n";  # Normal mode
                action = "<cmd>nohlsearch<CR>";  # Clear search highlights
                options = {
                  noremap = true;
                  silent = true;
                  desc = "Clear search highlights";
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
                  desc = "Lazygit";
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
                undodir = "/home/kixadmin/.config/nixvim/undo"; # Directory to store undo files
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
              #  codeium-nvim = {
              #    enable = true;
              #  };
              #  trouble = {
              #    enable = true;
              #    settings = {
              #     auto_close = true;       # Automatically close the list when you have no diagnostics
              #     auto_preview = true;     # Automatically preview the location of the diagnostic
              #     position = "bottom";     # Position of the list
              #     use_diagnostic_signs = true; # Use the signs defined in your LSP client
              #     height = 10;             # Height of the list when position is top or bottom
              #     width = 50;              # Width of the list when position is left or right
              #     icons = true;            # Use devicons for filenames
              #     mode = "workspace_diagnostics"; # Mode for default list
              #   };
              # };
              bufferline = {
                enable = true;
                settings = {
                  highlights = {
                    buffer_selected = {
                      bg = "#363a4f";
                    };
                    fill = {
                      bg = "#1e2030";
                    };
                    numbers_selected = {
                      bg = "#363a4f";
                    };
                    separator = {
                      fg = "#1e2030";
                    };
                    separator_selected = {
                      bg = "#363a4f";
                      fg = "#1e2030";
                    };
                    separator_visible = {
                      fg = "#1e2030";
                    };
                    tab_selected = {
                      bg = "#363a4f";
                    };
                  };
                  options = {
                    always_show_bufferline = true;
                    buffer_close_icon = "󰅖";
                    close_icon = "";
                    custom_filter = ''
                      function(buf_number, buf_numbers)
                        -- filter out filetypes you don't want to see
                        if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
                            return true
                        end
                        -- filter out by buffer name
                        if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
                            return true
                        end
                        -- filter out based on arbitrary rules
                        -- e.g. filter out vim wiki buffer from tabline in your work repo
                        if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
                            return true
                        end
                        -- filter out by its index number in list (don't show first buffer)
                        if buf_numbers[1] ~= buf_number then
                            return true
                        end
                      end
                    '';
                    diagnostics = "nvim_lsp";
                    diagnostics_indicator = ''
                      function(count, level, diagnostics_dict, context)
                        local s = ""
                        for e, n in pairs(diagnostics_dict) do
                          local sym = e == "error" and " "
                            or (e == "warning" and " " or "" )
                          if(sym ~= "") then
                            s = s .. " " .. n .. sym
                          end
                        end
                        return s
                      end
                    '';
                    enforce_regular_tabs = false;
                    get_element_icon = ''
                      function(element)
                        -- element consists of {filetype: string, path: string, extension: string, directory: string}
                        -- This can be used to change how bufferline fetches the icon
                        -- for an element e.g. a buffer or a tab.
                        local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
                        return icon, hl
                      end
                    '';
                    groups = {
                      items = [
                        {
                          highlight = {
                            fg = "#a6da95";
                            sp = "#494d64";
                            underline = true;
                          };
                          matcher = {
                            __raw = ''
                              function(buf)
                                return buf.name:match('%test') or buf.name:match('%.spec')
                              end
                            '';
                          };
                          name = "Tests";
                          priority = 2;
                        }
                        {
                          auto_close = false;
                          highlight = {
                            fg = "#ffffff";
                            sp = "#494d64";
                            undercurl = true;
                          };
                          matcher = {
                            __raw = ''
                              function(buf)
                                return buf.name:match('%.md') or buf.name:match('%.txt')
                              end
                            '';
                          };
                          name = "Docs";
                        }
                      ];
                      options = {
                        toggle_hidden_on_enter = true;
                      };
                    };
                    indicator = {
                      icon = "▎";
                      style = "icon";
                    };
                    left_trunc_marker = "";
                    max_name_length = 18;
                    max_prefix_length = 15;
                    mode = "buffers";
                    modified_icon = "●";
                    numbers = {
                      __raw = ''
                        function(opts)
                          return string.format('%s·%s', opts.raise(opts.id), opts.lower(opts.ordinal))
                        end
                      '';
                    };
                    offsets = [
                      {
                        filetype = "neo-tree";
                        highlight = "Directory";
                        text = "File Explorer";
                        text_align = "center";
                      }
                    ];
                    persist_buffer_sort = true;
                    right_trunc_marker = "";
                    separator_style = [
                      "|"
                      "|"
                    ];
                    show_buffer_close_icons = true;
                    show_buffer_icons = true;
                    show_close_icon = true;
                    show_tab_indicators = true;
                    sort_by = {
                      __raw = ''
                        function(buffer_a, buffer_b)
                            local modified_a = vim.fn.getftime(buffer_a.path)
                            local modified_b = vim.fn.getftime(buffer_b.path)
                            return modified_a > modified_b
                        end
                      '';
                    };
                    tab_size = 18;
                  };
                };
              };
              project-nvim = {
                  enable = true;
                  manualMode = false;  # Automatically change the directory
                  detectionMethods = ["lsp" "pattern"];
                  patterns = [".git" "Makefile" "package.json"];
              }; 
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
              cmp = {
                enable = true;
                autoEnableSources = true;
              };
              cmp-nvim-lsp.enable = true;
              lsp.servers = {
                nil-ls.enable = true;
                pyright.enable = true;
                tailwindcss.enable = true;
                tsserver.enable = true;
              };
              typescript-tools = {
                enable = true;
                settings = {
                  exposeAsCodeAction = "all";
                  tsserverFilePreferences = {
                    includeInlayParameterNameHints = "literals";
                     includeInlayFunctionParameterTypeHints = true;
                     includeInlayVariableTypeHints = false;
                     includeInlayPropertyDeclarationTypeHints = false;
                     includeInlayFunctionLikeReturnTypeHints = true;
                     includeInlayEnumMemberValueHints = false;
                     includeCompletionsForModuleExports = true;
                     importModuleSpecifierEnding = "minimal";
                     quotePreference = "single";
                   };
                 };
               };
              gitsigns.enable = true;
              nvim-tree = {
                enable = true;
                autoReloadOnWrite = true;
                hijackCursor = true;
                openOnSetup = true; # Automatically open tree on setup
                autoClose = false;  # Automatically close tree when it's the last window
                actions.openFile.quitOnOpen = true; # After selecting file, close the explorer automatically
                onAttach = {
                  __raw = ''
                    function(bufnr)
                      local api = require("nvim-tree.api")

                      local function opts(desc)
                        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                      end

                      -- Set NvimTree background color
                      vim.cmd("highlight NvimTreeNormal guibg=#000000")                      -- Custom mappings
                      
                            -- Set NvimTree text colors
                      vim.cmd("highlight NvimTreeFolderName guifg=#FFD700")  -- Bright yellow for directories
                      vim.cmd("highlight NvimTreeOpenedFile guifg=#00FF00")  -- Bright green for opened files
                      vim.cmd("highlight NvimTreeFileName guifg=#FFA500")    -- Orange for filenames
                      vim.cmd("highlight NvimTreeExecFile guifg=#FFA500")    -- Orange for executable files
                      vim.cmd("highlight NvimTreeSpecialFile guifg=#FFA500") -- Orange for special files
                      vim.cmd("highlight NvimTreeSymlink guifg=#FFA500")     -- Orange for symlinks
                      vim.cmd("highlight NvimTreeImageFile guifg=#FFA500")   -- Orange for image files

                      vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
                      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
                      vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                      vim.keymap.set("n", "a", api.fs.create, opts("Create"))
                      vim.keymap.set("n", "r", api.fs.remove, opts("Remove"))
                      vim.keymap.set("n", "d", api.fs.cut, opts("Cut"))
                      vim.keymap.set("n", "y", api.fs.copy.node, opts("Copy"))
                      vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
                    end
                  '';
                };
                extraOptions = {
                  view = {
                    adaptive_size = true;
                  };
                  renderer = {
                    highlight_opened_files = "all";
                  };
                };
              };
              nvim-snippets = {
                enable = true;
                settings = {
                  # create_autocmd = true;
                  # create_cmp_source = true;
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
              which-key = {
                enable = true;
                settings = {
                  delay = 1000; 
                  expand = 1;
                  notify = false;
                  preset = false;
                  ignore = {
                    keys = [ "c" ]; # Ignore the "c" key
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
