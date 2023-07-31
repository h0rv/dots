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
    use { 'tpope/vim-fugitive' }
    use { "windwp/nvim-autopairs", config = function() require("nvim-autopairs").setup {} end }
    use { 'numToStr/Comment.nvim' }
    use { 'nvim-tree/nvim-web-devicons' }
    -- use { 'romgrk/barbar.nvim', wants = 'nvim-web-devicons' }

    -- debug
    use { 'mfussenegger/nvim-dap' }
    use { 'rcarriga/nvim-dap-ui' }

    -- refactoring
    use { "ThePrimeagen/refactoring.nvim",
        requires = { { "nvim-lua/plenary.nvim" }, { "nvim-treesitter/nvim-treesitter" } }
    }

    use {
        'nvim-tree/nvim-tree.lua',
        requires = { 'nvim-tree/nvim-web-devicons', },
        tag = 'nightly' -- optional, updated every week. (see issue #1193)
    }

    use { 'sbdchd/neoformat' }

    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            -- Snippet Collection (Optional)
            { 'rafamadriz/friendly-snippets' },
        }
    }

    -- Lua
    use {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end
    }


	-- Theme
	use { 'folke/zen-mode.nvim' }
	use { 'folke/twilight.nvim' }
	use { 'HampusHauffman/block.nvim' }

    use { 'nvim-lualine/lualine.nvim' }
    use { 'lukas-reineke/indent-blankline.nvim' }

    use { 'catppuccin/nvim', as = 'catppuccin' }
    use { 'kyazdani42/blue-moon' }
    use { 'navarasu/onedark.nvim' }
    use { 'Everblush/everblush.nvim', as = 'everblush' }
    use { 'rose-pine/neovim' }
    use { 'sainnhe/gruvbox-material' }
    use { 'nyoom-engineering/oxocarbon.nvim' }
    use { 'rebelot/kanagawa.nvim' }
    use { 'Yazeed1s/oh-lucy.nvim' }
end)
