return {
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { "saadparwaiz1/cmp_luasnip",         dependencies = { "rafamadriz/friendly-snippets" }, },
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },

            -- Snippets
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",                -- follow latest release. Replace <CurrentMajor> by the latest released major (first number of latest release)
                build = "make install_jsregexp", -- install jsregexp (optional!:).
            },
            { "David-Kunz/cmp-npm",          dependencies = { "nvim-lua/plenary.nvim", } },
            -- Snippet Collection (Optional)
            { "rafamadriz/friendly-snippets" },
        }
    },
}
