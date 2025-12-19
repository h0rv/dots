-- ============================================================================
-- Plugin configurations
--
-- This file loads all plugin configurations in order.
-- Each feature is organized into its own module for maintainability.
-- ============================================================================

vim.pack.add({
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/nvim-tree/nvim-tree.lua",
    "https://github.com/nvim-tree/nvim-web-devicons", -- optional icons (Nerd Font)
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/mfussenegger/nvim-lint",
})

vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
end, { desc = "Update plugins via vim.pack (review tab, then :write to apply)" })

-- UI & Visual
require("config.plugins.colorscheme")
require("config.plugins.treesitter")

-- Navigation
require("config.plugins.file-explorer")
require("config.plugins.fuzzy-finder")

-- Language Support
require("config.plugins.lsp")
require("config.plugins.formatting")
require("config.plugins.linting")

require("config.plugins.which-key")
