local set = vim.opt

set.number = true
set.relativenumber = true
set.ruler = false
set.showtabline = 0 -- remove tab line
-- current line number highlight
set.cursorline = true
set.cursorlineopt = 'number'

set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.expandtab = true

set.smartindent = true

set.wrap = false

set.swapfile = false
set.backup = false
set.undodir = os.getenv('HOME') .. '/.vim/undodir'
set.undofile = true

set.ignorecase = true
set.smartcase = true
set.hlsearch = true
set.incsearch = true

set.termguicolors = true

set.scrolloff = 8
set.signcolumn = "yes"

set.updatetime = 250

set.fillchars = 'eob: ' -- removes '~' at end of buffer

set.completeopt = 'menuone,noselect'

set.showcmd = false

-- now using nvim-ufo for folding
-- folding
-- set.foldmethod = 'expr'
-- set.foldexpr = 'nvim_treesitter#foldexpr()'
-- set.foldlevel = 10

-- Restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
    end,
})

-- Haskell
vim.cmd [[autocmd FileType haskell setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2 ]]

-- Markdown
vim.cmd [[autocmd FileType markdown setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2 wrap breakindent lbr]]
-- Text
vim.cmd [[autocmd FileType text setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2 wrap breakindent lbr]]
