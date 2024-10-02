return {
    -- Fuzzy Finder (files, lsp, etc)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { { "nvim-lua/plenary.nvim" } }
    },
    -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = vim.fn.executable "make" == 1
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },
    {
        'MagicDuck/grug-far.nvim',
        config = function()
            require('grug-far').setup({});
        end
    },
}
