-- Neovim options configuration
-- All vim.opt and vim.g settings

local g = vim.g
local opt = vim.opt

-- Leader keys (must be set before keymaps)
g.mapleader = ' '              -- Set the leader key to space, used as a prefix for custom key mappings
g.maplocalleader = ' '         -- Set the local leader key to space, used for buffer-local key mappings

-- Indentation settings
opt.shiftwidth = 4             -- Number of spaces used for each step of (auto)indent
opt.tabstop = 4                -- Number of spaces that a <Tab> in the file counts for
opt.expandtab = true           -- Use spaces instead of tabs when inserting a tab character

-- Line numbers
opt.number = true               -- Print the line number in front of each line
opt.relativenumber = true      -- Show the line number relative to the line with the cursor

-- Clipboard
opt.clipboard = "unnamedplus"  -- Use the system clipboard for yank/put operations (unnamedplus register)

-- Scrolling
opt.scrolloff = 20             -- Minimal number of screen lines to keep above and below the cursor

-- Tabline (custom buffer display)
opt.showtabline = 2            -- Always show tabline (like browser tabs)

-- Window options
vim.wo.wrap = false            -- Don't wrap long lines (window-local option)
