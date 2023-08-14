-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
    vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function(use)
    -- Packer can manage itself
    use { 'wbthomason/packer.nvim' }

    -- Fuzzy Finder (files, lsp, etc)
    use { 'nvim-telescope/telescope.nvim', tag = '0.1.0', requires = { { 'nvim-lua/plenary.nvim' } } }
    -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    -- use { 'filNaj/tree-setter' }
    use { 'tpope/vim-fugitive' }
    use { "windwp/nvim-autopairs", config = function() require("nvim-autopairs").setup {} end }
    use { 'numToStr/Comment.nvim' }
    use { 'nvim-tree/nvim-web-devicons' }
    use { 'romgrk/barbar.nvim', wants = 'nvim-web-devicons' }
    use { 'willothy/flatten.nvim' }

    -- debug
    -- https://miguelcrespo.co/posts/debugging-javascript-applications-with-neovim
    use { 'mfussenegger/nvim-dap' }
    use { "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" } }
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
    use { "microsoft/vscode-js-debug",
        opt = true,
        run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
    }
    use { 'Joakker/lua-json5',
        run = './install.sh'
    }

    -- refactoring
    use { "ThePrimeagen/refactoring.nvim",
        requires = { { "nvim-lua/plenary.nvim" }, { "nvim-treesitter/nvim-treesitter" } }
    }

    use { 'sbdchd/neoformat' }

    -- navigation
    use { 'ggandor/leap.nvim',
        requires = { 'tpope/vim-repeat', },
        config = function()
            require('leap').add_default_mappings()
        end
    }

    use { 'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'saadparwaiz1/cmp_luasnip',         requires = { 'rafamadriz/friendly-snippets' }, },
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            use { 'L3MON4D3/LuaSnip',
                tag = 'v2.*',                  -- follow latest release. Replace <CurrentMajor> by the latest released major (first number of latest release)
                run = 'make install_jsregexp', -- install jsregexp (optional!:).
            },
            { 'David-Kunz/cmp-npm',          requires = { 'nvim-lua/plenary.nvim', } },
            -- Snippet Collection (Optional)
            { 'rafamadriz/friendly-snippets' },
        }
    }

    use { "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end
    }

    use { "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    }

    use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

    use { 'nvim-pack/nvim-spectre', requires = { 'nvim-lua/plenary.nvim' } }

    use { 'ThePrimeagen/harpoon', require = { 'nvim-lua/plenary.nvim', }, }

    -- Start screen
    use { 'goolord/alpha-nvim', requires = { 'nvim-tree/nvim-web-devicons' } }

    -- Theme
    use { 'folke/zen-mode.nvim' }
    use { 'folke/twilight.nvim' }
    -- use { 'HampusHauffman/block.nvim' }
    use { 'tamton-aquib/zone.nvim' }

    use { 'folke/noice.nvim',
        requires = {
            'MunifTanjim/nui.nvim',
            -- 'rcarriga/nvim-notify', -- optional
        }
    }

    use { 'nvim-lualine/lualine.nvim' }
    use { 'lukas-reineke/indent-blankline.nvim' }

    use { 'catppuccin/nvim', as = 'catppuccin' }
    use { 'kyazdani42/blue-moon' }
    use { 'navarasu/onedark.nvim' }
    use { 'Everblush/everblush.nvim', as = 'everblush' }
    -- use { 'rose-pine/neovim' }
    use { 'sainnhe/gruvbox-material' }
    use { 'nyoom-engineering/oxocarbon.nvim' }
    use { 'rebelot/kanagawa.nvim' }
    use { 'Yazeed1s/oh-lucy.nvim' }
end)
