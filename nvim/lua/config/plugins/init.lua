-- Plugin configurations
-- Each feature is organized into its own module.

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local data = ev.data or {}
        local spec = data.spec or {}
        if spec.name ~= "cursortab.nvim" or (data.kind ~= "install" and data.kind ~= "update") then
            return
        end
        if vim.fn.executable("go") == 0 then
            return
        end
        local binary = "cursortab"
        if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
            binary = binary .. ".exe"
        end
        vim.system({ "go", "build", "-o", binary }, {
            cwd = vim.fs.joinpath(data.path, "server"),
            text = true,
        })
    end,
})

vim.pack.add({
    "https://github.com/benlubas/molten-nvim",
    "https://github.com/GCBallesteros/jupytext.nvim",
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/f4z3r/gruvbox-material.nvim",
    "https://github.com/gthelding/monokai-pro.nvim",
    "https://github.com/folke/snacks.nvim",
    "https://github.com/folke/persistence.nvim",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/alexghergh/nvim-tmux-navigation",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/mfussenegger/nvim-lint",
    "https://github.com/sindrets/diffview.nvim",
    "https://github.com/clabby/difftastic.nvim",
    "https://github.com/folke/flash.nvim",
    "https://github.com/cursortab/cursortab.nvim",
    "https://github.com/nvim-mini/mini.surround",
    -- "https://github.com/pablopunk/pi.nvim",
    -- { src = "https://github.com/h0rv/pi.nvim", version = "persistent-rpc" },
}, { confirm = false })

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
require("config.plugins.surround")

-- Session
require("config.plugins.session")

-- Language Support
require("config.plugins.lsp")
require("config.plugins.formatting")
require("config.plugins.linting")
require("config.plugins.notebook")

-- AI
-- require("config.plugins.cursortab")
-- require("config.plugins.pi")

-- Git
require("config.plugins.diff")

-- Keys
require("config.plugins.which-key")
