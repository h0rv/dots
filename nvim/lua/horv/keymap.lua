local set = vim.keymap.set
local cmd = vim.cmd
local g = vim.g

g.mapleader = ' '
g.maplocalleader = ' '

set('n', '<leader>e', cmd.NvimTreeToggle)

set('n', '<leader>W', cmd.w)
set('n', '<leader>Q', cmd.q)

set('n', '<S-h>', '<C-w>h')
set('n', '<S-j>', '<C-w>j')
set('n', '<S-k>', '<C-w>k')
set('n', '<S-l>', '<C-w>l')

set('i', 'jk', '<ESC>')
set('i', 'kj', '<ESC>')

set('v', 'J', ":m '>+1<CR>gv=gv")
set('v', 'K', ":m '<-2<CR>gv=gv")

set('n', 'J', 'mzJ`z')
set('n', '<C-d>', '<C-d>zz')
set('n', '<C-u>', '<C-u>zz')
set('n', 'n', 'nzzzv')
set('n', 'N', 'Nzzzv')

set('n', '<leader>y', '\"+y')
set('v', '<leader>y', '\"+y')
set('n', '<leader>Y', '\"+Y')

set('n', 'Q', '<nop>')

set('n', '<leader>f', vim.lsp.buf.format)
set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

set('n', '<leader>pm', '<cmd>e ~/.config/nvim/lua/horv/packer.lua<CR>');

-- Diagnostic keymaps
local diag = vim.diagnostic
set('n', '[d', diag.goto_prev)
set('n', ']d', diag.goto_next)
set('n', '<leader>d', diag.open_float)

-- from nvim-lua/kickstart.nvim
-- Keymaps for better default experience
set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

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
