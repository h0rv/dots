return {
    { "romgrk/barbar.nvim",                  dependencies = "nvim-web-devicons" },
    { "folke/zen-mode.nvim" },
    { "folke/twilight.nvim" },
    { "tamton-aquib/zone.nvim" },
    { "nvim-lualine/lualine.nvim" },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl",                      opts = {} },
    {
        "mawkler/modicator.nvim",
        dependencies = "mawkler/onedark.nvim", -- Add your colorscheme plugin here
        init = function()
            -- These are required for Modicator to work
            vim.o.cursorline = true
            vim.o.number = true
            vim.o.termguicolors = true
        end,
        opts = {}
    },
}
