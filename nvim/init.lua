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
opt.scrolloff = 20

vim.wo.wrap = false

local set = vim.keymap.set
local cmd = vim.cmd
set('i', 'jk', '<ESC>')
set('i', 'kj', '<ESC>')
set('n', '<leader>W', cmd.w, { desc = '[W]rite' })
set("n", "<leader>f", vim.lsp.buf.format)
set("n", "<leader>r",
    function()
        -- when rename opens the prompt, this autocommand will trigger
        -- it will "press" CTRL-F to enter the command-line window `:h cmdwin`
        -- in this window I can use normal mode keybindings
        local cmdId
        cmdId = vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
            callback = function()
                local key = vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
                vim.api.nvim_feedkeys(key, "c", false)
                vim.api.nvim_feedkeys("0", "n", false)
                -- autocmd was triggered and so we can remove the ID and return true to delete the autocmd
                cmdId = nil
                return true
            end,
        })
        vim.lsp.buf.rename()
        -- if LPS couldn't trigger rename on the symbol, clear the autocmd
        vim.defer_fn(function()
            -- the cmdId is not nil only if the LSP failed to rename
            if cmdId then
                vim.api.nvim_del_autocmd(cmdId)
            end
        end, 500)
    end
)
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
