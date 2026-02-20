local project = require("config.project")

-- Find the nearest package root (package.json, Cargo.toml, pyproject.toml, go.mod, mix.exs)
-- Falls back to git root if no package marker is found
local package_markers = { "package.json", "Cargo.toml", "pyproject.toml", "go.mod", "mix.exs" }

local function package_root()
    local buf = vim.api.nvim_buf_get_name(0)
    if buf == "" then return project.project_root(0) end
    local dir = vim.fs.dirname(buf)
    local hit = vim.fs.find(package_markers, { path = dir, upward = true, stop = project.project_root(0) })[1]
    if hit then return vim.fs.dirname(hit) end
    return project.project_root(0)
end

require("snacks").setup({
    picker = { enabled = true },
    explorer = { enabled = true },
    dashboard = {
        enabled = true,
        preset = {
            keys = {
                { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
                { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
                { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
                { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
                { icon = "󰒲 ", key = "u", desc = "Update Plugins", action = ":PackUpdate" },
                { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
        },
        sections = {
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
            { section = "recent_files", padding = 1 },
        },
    },
    bufdelete = { enabled = true },
    notifier = { enabled = true },
    indent = { enabled = true },
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    lazygit = { enabled = true },
    terminal = { enabled = true },
    gitbrowse = { enabled = true },
})

local set = vim.keymap.set

-- Picker
set("n", "<leader>ff", function()
    Snacks.picker.files({ cwd = project.project_root(0) })
end, { desc = "Find files" })

set("n", "<leader>fg", function()
    Snacks.picker.grep({ cwd = project.project_root(0) })
end, { desc = "Live grep" })

set("n", "<leader>fb", function()
    Snacks.picker.buffers()
end, { desc = "Buffers" })

set("n", "<leader>fr", function()
    Snacks.picker.resume()
end, { desc = "Resume picker" })

set("n", "<leader>fs", function()
    Snacks.picker.lsp_symbols()
end, { desc = "Symbols (document)" })

set("n", "<leader>fS", function()
    Snacks.picker.lsp_workspace_symbols()
end, { desc = "Symbols (workspace)" })

-- Scope to nearest package (auto-detected from package.json, Cargo.toml, etc.)
set("n", "<leader>fp", function()
    local root = package_root()
    Snacks.picker.files({ cwd = root })
end, { desc = "Find files (package)" })

set("n", "<leader>fP", function()
    local root = package_root()
    Snacks.picker.grep({ cwd = root })
end, { desc = "Grep (package)" })

-- Manual subdir scope
set("n", "<leader>fd", function()
    vim.ui.input({ prompt = "Subdir: " }, function(input)
        if input and input ~= "" then
            Snacks.picker.files({ cwd = project.project_root(0) .. "/" .. input })
        end
    end)
end, { desc = "Find files in subdir" })

-- Explorer
set("n", "<leader>e", function()
    Snacks.explorer()
end, { desc = "Explorer toggle" })

set("n", "<leader>o", function()
    Snacks.explorer.reveal()
end, { desc = "Explorer reveal" })

-- Buffer delete
set("n", "<leader>bd", function()
    Snacks.bufdelete()
end, { desc = "Delete buffer" })

set("n", "<leader>bD", function()
    Snacks.bufdelete.all()
end, { desc = "Delete all buffers" })

-- Lazygit
set("n", "<leader>gg", function()
    Snacks.lazygit()
end, { desc = "Lazygit" })

-- Git browse
set("n", "<leader>gB", function()
    Snacks.gitbrowse()
end, { desc = "Open on GitHub" })

-- Terminal
set("n", "<leader>;", function()
    Snacks.terminal()
end, { desc = "Terminal" })
