local set = vim.keymap.set

set('n', '<leader>e', vim.cmd.Lexplore)

set('n', '<leader>w', vim.cmd.w)
set('n', '<leader>q', vim.cmd.q)

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

set('n', '<leader>f', function() vim.lsp.buf.format() end)

set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
