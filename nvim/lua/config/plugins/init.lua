-- Plugin configurations
-- Each feature is organized into its own module.

vim.pack.add({
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/folke/snacks.nvim",
    "https://github.com/folke/persistence.nvim",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/alexghergh/nvim-tmux-navigation",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/mfussenegger/nvim-lint",
    "https://github.com/sindrets/diffview.nvim",
    "https://github.com/folke/flash.nvim",
})

vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
end, { desc = "Update plugins via vim.pack (review tab, then :write to apply)" })

-- UI & Visual
require("config.plugins.colorscheme")
require("config.plugins.treesitter")

-- Navigation & UI
require("config.plugins.snacks")
require("config.plugins.tmux-nav")
require("config.plugins.flash")

-- Session
require("config.plugins.session")

-- Language Support
require("config.plugins.lsp")
require("config.plugins.formatting")
require("config.plugins.linting")

-- Git
require("config.plugins.diff")

-- Keys
require("config.plugins.which-key")
