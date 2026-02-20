-- ============================================================================
-- Plugin configurations
--
-- This file loads all plugin configurations in order.
-- Each feature is organized into its own module for maintainability.
-- ============================================================================

vim.pack.add({
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/nvim-neo-tree/neo-tree.nvim",
    "https://github.com/nvim-lua/plenary.nvim",
    -- "https://github.com/mikavilpas/yazi.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons", -- optional icons (Nerd Font)
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/mfussenegger/nvim-lint",
    "https://github.com/serhez/bento.nvim",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/leonardcser/cursortab.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/esmuellert/codediff.nvim",
    "https://github.com/sindrets/diffview.nvim",
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
end, { desc = "Update plugins via vim.pack (review tab, then :write to apply)" })

-- UI & Visual
require("config.plugins.colorscheme")
require("config.plugins.treesitter")
require("config.plugins.markdown")

-- Navigation
require("config.plugins.file-explorer")
require("config.plugins.fuzzy-finder")
require("config.plugins.bento")
require("config.plugins.oil")

-- Language Support
require("config.plugins.lsp")
require("config.plugins.formatting")
require("config.plugins.linting")

require("config.plugins.which-key")

require("config.plugins.diff")

-- AI
-- require("config.plugins.cursortab")
