local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 }, -- color scheme (-> setup in colorscheme.lua)
    { 
      "saghen/blink.cmp",
      dependencies = { "rafamadriz/friendly-snippets" },
      version = "*",
      opts = {
        keymap = {
          preset = "super-tab",
        },
        
        appearance = {
          nerd_font_variant = "mono",
        },
        
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" },

        completion = {
                -- The keyword should only match against the text before
                keyword = { range = "prefix" },
                menu = {
                    -- Use treesitter to highlight the label text for the given list of sources
                    draw = {
                        treesitter = { "lsp" },
                    },
                },
                -- Show completions after typing a trigger character, defined by the source
                trigger = { show_on_trigger_character = true },
                documentation = {
                    -- Show documentation automatically
                    auto_show = true,
                },
            },
        signature = { enabled = true },
      },
      opts_extend = { "sources.default" },
    },
    { "mason-org/mason.nvim", opts = {} }, -- needed for LSP
    { 'wakatime/vim-wakatime', lazy = false },
    {
            "rebelot/heirline.nvim",
            dependencies = {
                    { "nvim-tree/nvim-web-devicons", opts = {} },
                    -- { "nvim-lua/lsp-status.nvim" },
                    {
                            "lewis6991/gitsigns.nvim",
                            config = function()
                                    require("gitsigns").setup()
                            end,
                    },
                    {
                            "SmiteshP/nvim-navic",
                            dependencies = { "neovim/nvim-lspconfig" },
                            config = function()
                                    require("nvim-navic").setup({
                                            lsp = {
                                                    auto_attach = true,
                                            },
                                            separator = " > ",
                                            safe_output = true,
                                    })
                            end,
                    },
            },
    },
        {
            "fiqryq/wakastat.nvim",
            event = "VeryLazy",
            cmd = { "WakastatRefresh", "WakastatStatus"},
            opts = {
                    args = { "--today" },
                    format = "Today Coding Time: %s",
                    update_interval = 300,
                    enable_timer = true,
            },
            config = function(_, opts)
                    require("wakastat").setup(opts)
            end;
        },
        --[[{
                "m4xshen/autoclose.nvim",
                config = function()
                        require("autoclose").setup()
                end,
        },]]
        {
                "nvim-tree/nvim-tree.lua",
                version = "*",
                lazy = false,
                dependencies = { "nvim-tree/nvim-web-devicons" },
                config = function()
                        require("nvim-tree").setup({
                                on_attach = require("plugins.nvim-tree-mappings"),
                                actions = {
                                        open_file = {
                                                quit_on_open = true,
                                        }
                                }
                        })
                end,
        },
        {
                "nvim-java/nvim-java",
                config = function()
                        require("java").setup({
                                jdk = {
                                        auto_install = false,
                                        version = '21',
                                }
                        })
                end,
        },
        {
                "NoahTheDuke/vim-just",
                ft = { "just" },
        },
        {
                "windwp/nvim-autopairs",
                event = "InsertEnter",
                config = true
        },
        {
                "windwp/nvim-ts-autotag",
                config = function()
                        require("nvim-ts-autotag").setup({
                                opts = {
                                        enable_close = true,
                                        enable_rename = true,
                                        enable_close_on_slash = false
                                }
                        })
                end,
        },
})
