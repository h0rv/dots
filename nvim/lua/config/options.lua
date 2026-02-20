-- Neovim options

local g = vim.g
local opt = vim.opt

-- Leader keys (must be set before keymaps)
g.mapleader = ' '
g.maplocalleader = ' '

-- Disable netrw (snacks.explorer replaces it)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.showtabline = 2

-- Indentation
opt.shiftwidth = 4
opt.tabstop = 4
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

-- Clipboard
opt.clipboard = "unnamedplus"

-- Windows
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.scrolloff = 20
vim.wo.wrap = false

-- Performance
opt.updatetime = 200
opt.timeoutlen = 400

-- Files
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.writebackup = false
opt.swapfile = false
opt.shada = "!,'200,<50,s10,h"

-- Completion
opt.completeopt = { "menuone", "noselect", "popup" }

-- Mouse
opt.mouse = "a"
