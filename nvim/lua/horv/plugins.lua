local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { { 'nvim-lua/plenary.nvim' } }
    },
    -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable 'make' == 1
    },

    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    { 'tpope/vim-fugitive' },
    { 'windwp/nvim-autopairs',           event = "InsertEnter",             opts = {} },
    { 'numToStr/Comment.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
    { 'romgrk/barbar.nvim',              dependencies = 'nvim-web-devicons' },

    -- Debuging (https://miguelcrespo.co/posts/debugging-javascript-applications-with-neovim)
    -- { 'mfussenegger/nvim-dap' },
    -- { "mxsdev/nvim-dap-vscode-js",       dependencies = { "mfussenegger/nvim-dap" } },
    -- { "rcarriga/nvim-dap-ui",            dependencies = { "mfussenegger/nvim-dap" } },
    -- { 'Joakker/lua-json5',               build = './install.sh', name = 'json5' },
    -- { "microsoft/vscode-js-debug",
    --     opt = true,
    --     build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
    -- }

    { 'sbdchd/neoformat' },

    -- navigation
    {
        'ggandor/leap.nvim',
        dependencies = { 'tpope/vim-repeat', },
        config = function()
            require('leap').add_default_mappings()
        end
    },

    {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'saadparwaiz1/cmp_luasnip',         dependencies = { 'rafamadriz/friendly-snippets' }, },
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            {
                'L3MON4D3/LuaSnip',
                version = 'v2.*',                -- follow latest release. Replace <CurrentMajor> by the latest released major (first number of latest release)
                build = 'make install_jsregexp', -- install jsregexp (optional!:).
            },
            { 'David-Kunz/cmp-npm',          dependencies = { 'nvim-lua/plenary.nvim', } },
            -- Snippet Collection (Optional)
            { 'rafamadriz/friendly-snippets' },
        }
    },

    {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end
    },

    { "kylechui/nvim-surround", },

    { 'kevinhwang91/nvim-ufo',  dependencies = 'kevinhwang91/promise-async' },

    -- Start screen
    { 'goolord/alpha-nvim',     dependencies = { 'nvim-tree/nvim-web-devicons' } },

    -- Theme
    { 'folke/zen-mode.nvim' },
    { 'folke/twilight.nvim' },
    { 'tamton-aquib/zone.nvim' },
    {
        'folke/noice.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
            -- 'rcarriga/nvim-notify', -- optional
        }
    },
    { 'nvim-lualine/lualine.nvim' },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl",       opts = {} },
    -- Colorschemes
    { 'catppuccin/nvim',                     name = 'catppuccin' },
    { 'Everblush/everblush.nvim',            name = 'everblush' },
    { "folke/tokyonight.nvim",               lazy = false,       priority = 1000, opts = {}, },
    { 'navarasu/onedark.nvim' },
    { 'sainnhe/gruvbox-material' },
    { 'nyoom-engineering/oxocarbon.nvim' },
    { 'rebelot/kanagawa.nvim' },
    { 'Yazeed1s/oh-lucy.nvim' },
    { 'kvrohit/mellow.nvim' },
})
