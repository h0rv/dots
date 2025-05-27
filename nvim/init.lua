local g = vim.g
g.mapleader = ' '
g.maplocalleader = ' '

require("config.lazy")

local opt = vim.opt
opt.shiftwidth = 4
opt.tabstop = 4
opt.expandtab = true
opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamedplus"

vim.wo.wrap = false

local set = vim.keymap.set
local cmd = vim.cmd
set('i', 'jk', '<ESC>')
set('i', 'kj', '<ESC>')
set('n', '<leader>W', cmd.w, { desc = '[W]rite' })
set("n", "<leader>f", vim.lsp.buf.format)
set("n", "<leader>e", MiniFiles.open)

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})
