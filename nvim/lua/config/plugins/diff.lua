require("codediff").setup({
  explorer = {
    view_mode = "tree",
    indent_markers = true,
  },
})

vim.keymap.set("n", "<leader>dd", "<cmd>CodeDiff<cr>", { desc = "CodeDiff changes" })
vim.keymap.set("n", "<leader>dm", "<cmd>CodeDiff main<cr>", { desc = "CodeDiff vs main" })

vim.o.autoread = true
vim.o.updatetime = 1000

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    vim.cmd("checktime")
  end,
})

vim.opt.diffopt:append({
  "algorithm:histogram",  -- much better than the default myers
  "linematch:60",         -- intra-hunk line matching (NeoVim 0.9+)
  "indent-heuristic",     -- smarter hunk boundaries
})

require("diffview").setup({
  watch_index = true,
})

vim.keymap.set("n", "<leader>dw", "<cmd>DiffviewOpen<cr>", { desc = "Diffview watch" })
vim.keymap.set("n", "<leader>dr", "<cmd>DiffviewRefresh<cr>", { desc = "Refresh diffview" })
vim.keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<cr>", { desc = "Diffview close" })
