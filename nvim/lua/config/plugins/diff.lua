vim.opt.diffopt:append({
    "algorithm:histogram",
    "linematch:60",
    "indent-heuristic",
})

require("diffview").setup({
    watch_index = true,
})

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diff open" })
vim.keymap.set("n", "<leader>gm", "<cmd>DiffviewOpen main<cr>", { desc = "Diff vs main" })
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Diff close" })
