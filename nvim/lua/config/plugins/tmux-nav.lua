local nav = require("nvim-tmux-navigation")

nav.setup({
    disable_when_zoomed = true,
})

vim.keymap.set("n", "<C-h>", nav.NvimTmuxNavigateLeft, { desc = "Navigate left" })
vim.keymap.set("n", "<C-j>", nav.NvimTmuxNavigateDown, { desc = "Navigate down" })
vim.keymap.set("n", "<C-k>", nav.NvimTmuxNavigateUp, { desc = "Navigate up" })
vim.keymap.set("n", "<C-l>", nav.NvimTmuxNavigateRight, { desc = "Navigate right" })
