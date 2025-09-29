-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        { "folke/tokyonight.nvim" },
        { 'AlexvZyl/nordic.nvim' },
        { "ilof2/posterpole.nvim" },
        { "mellow-theme/mellow.nvim" },
        {
            'everviolet/nvim',
            name = 'evergarden',
            opts = {
                theme = {
                    variant = 'fall', -- 'winter'|'fall'|'spring'|'summer'
                    accent = 'green',
                },
            }
        },
        {
            "loctvl842/monokai-pro.nvim",
            config = function()
                require("monokai-pro").setup({
                    filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
                })
            end
        },
        {
            "darianmorat/gruvdark.nvim",
            lazy = false,
            priority = 1000,
            opts = {},
        },
        {
            "gruvw/strudel.nvim",
            build = "npm install",
            config = function()
                require("strudel").setup()
            end,
        },
        { import = "config.plugins" },
    },
})

-- vim.cmd.colorscheme "tokyonight-night"
-- vim.cmd.colorscheme "evergarden"
-- vim.cmd.colorscheme "posterpole"
vim.cmd.colorscheme "monokai-pro"
-- vim.cmd.colorscheme "gruvdark"
