local fzf = require("fzf-lua")
local project = require("config.project")

fzf.setup({})

local function root_cwd()
    return project.project_root(0)
end

-- VS Code muscle memory (may depend on terminal passing <D-...> keys)
vim.keymap.set("n", "<D-p>", function()
    fzf.files({ cwd = root_cwd() })
end, { desc = "Cmd+P: find files" })

vim.keymap.set("n", "<leader>ff", function()
    fzf.files({ cwd = root_cwd() })
end, { desc = "Find files (root)" })

vim.keymap.set("n", "<leader>fg", function()
    fzf.live_grep({ cwd = root_cwd() })
end, { desc = "Live grep (root)" })

vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "Resume last picker" })

vim.keymap.set("n", "<leader>fV", function()
    fzf.files({ cwd = root_cwd() .. "/.venv", prompt = "Venv> " })
end, { desc = "Find files in .venv" })

vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Symbols (document)" })
vim.keymap.set("n", "<leader>fS", fzf.lsp_workspace_symbols, { desc = "Symbols (workspace)" })
