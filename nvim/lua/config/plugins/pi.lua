require("pi").setup({
  -- provider = "openrouter",
  -- model = "openrouter/free",
  thinking = "off", -- be careful, thinking is time-consuming, it's not a great experience if you want simplicity
  skills = true,
  extensions = false,
  rpc = {
    persistent = true,  -- default: false
    start = "setup",     -- "lazy" | "setup"
  }
})
-- Ask pi with the current buffer as context
vim.keymap.set("n", "<leader>p", ":PiAsk<CR>", { desc = "Ask pi" })

-- Ask pi with visual selection as context
-- im testing
vim.keymap.set("v", "<leader>p", ":PiAskSelection<CR>", { desc = "Ask pi (selection)" })
