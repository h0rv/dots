-- require("tokyonight").setup({
--     style = "night",
-- })
-- vim.cmd.colorscheme("tokyonight")

require("gruvbox-material").setup({
      contrast = "medium", -- set contrast, can be any of "hard", "medium", "soft"
})
vim.cmd.colorscheme("gruvbox-material")

-- Follow the macOS system appearance. auto-dark-mode polls the OS and flips
-- vim.o.background; gruvbox-material reads &background and repaints, so light
-- mode gives "Gruvbox Material Light" with no restart needed.
require("auto-dark-mode").setup({
    update_interval = 3000,
    set_dark_mode = function()
        vim.o.background = "dark"
        vim.cmd.colorscheme("gruvbox-material")
    end,
    set_light_mode = function()
        vim.o.background = "light"
        vim.cmd.colorscheme("gruvbox-material")
    end,
})

-- require("monokai-pro").setup({
-- filter = "ristretto",
-- override = function()
--   return {
--     NonText = { fg = "#948a8b" },
--     MiniIconsGrey = { fg = "#948a8b" },
--     MiniIconsRed = { fg = "#fd6883" },
--     MiniIconsBlue = { fg = "#85dacc" },
--     MiniIconsGreen = { fg = "#adda78" },
--     MiniIconsYellow = { fg = "#f9cc6c" },
--     MiniIconsOrange = { fg = "#f38d70" },
--     MiniIconsPurple = { fg = "#a8a9eb" },
--     MiniIconsAzure = { fg = "#a8a9eb" },
--     MiniIconsCyan = { fg = "#85dacc" }, -- same value as MiniIconsBlue for consistency
--   }
-- end,
-- })
-- vim.cmd.colorscheme("monokai-pro")
