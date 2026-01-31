local ts = require("nvim-treesitter")

-- Add nvim-treesitter runtime to runtimepath for queries
local ts_runtime = vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-treesitter/runtime"
if vim.fn.isdirectory(ts_runtime) == 1 then
    vim.opt.runtimepath:prepend(ts_runtime)
end

ts.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Install parsers on-demand (NOT every startup)
vim.api.nvim_create_user_command("TSBootstrap", function()
    ts.install({
        "python", "lua", "vim", "vimdoc",
        "markdown", "json", "toml", "yaml", "bash", "dockerfile",
        "javascript", "typescript",
        "elixir", "heex",
    }):wait(300000)
end, { desc = "Install core Treesitter parsers (run once)" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "python", "lua", "vim", "vimdoc",
        "markdown", "json", "toml", "yaml", "bash", "dockerfile",
        "javascript", "typescript",
        "elixir", "heex",
    },
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Treesitter-based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
