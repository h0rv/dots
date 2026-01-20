-- require("nvim-tree").setup({
--     view = { width = 34 },
--     renderer = { group_empty = true },
--     filters = {
--         dotfiles = false, -- Show dotfiles (e.g., .venv)
--         custom = { "^\\.git$" },
--     },
--     update_focused_file = {
--         enable = true,
--         update_root = false,
--     },
--     sync_root_with_cwd = true,
--     respect_buf_cwd = true,
--
--     on_attach = function(bufnr)
--         local api = require("nvim-tree.api")
--
--         local function opts(desc)
--             return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true }
--         end
--
--         -- Open file / expand directory
--         vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
--
--         -- Optional: keep Vim muscle memory
--         vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close directory"))
--     end,
-- })
--
-- vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Explorer: toggle" })
-- vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFindFile<CR>", { desc = "Explorer: reveal file" })

require("yazi").setup({
    open_for_directories = false,
    keymaps = {
        show_help = "<f1>",
    },
})
-- Yazi: toggle (resume last session by default)
vim.keymap.set("n", "<leader>e", "<cmd>Yazi toggle<CR>", { desc = "Explorer: yazi (resume/toggle)" })

-- Optional: open in cwd (fresh)
vim.keymap.set("n", "<leader>E", "<cmd>Yazi cwd<CR>", { desc = "Explorer: yazi (cwd)" })

-- Optional: open at current file (fresh)
vim.keymap.set({ "n", "v" }, "<leader>o", "<cmd>Yazi<CR>", { desc = "Explorer: yazi (at file)" })
