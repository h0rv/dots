require('telescope').setup {
    defaults = {
        file_ignore_patterns = {
            "node_modules",
            ".git/",
        },
        mappings = {
            i = {
                ['<C-j>'] = require('telescope.actions').move_selection_next,
                ['<C-k>'] = require('telescope.actions').move_selection_previous,
                ['<C-l>'] = require('telescope.actions').select_default,
                ['kj'] = 'close',
                ['jk'] = 'close',
            },
        },
    },
}

require("telescope").load_extension "file_browser"

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

local builtin = require('telescope.builtin')
local set = vim.keymap.set

set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })

set('n', '<leader>sf',
    function()
        builtin.find_files({
            hidden = true,
            no_ignore = false,
            no_ignore_parent = false
        })
    end, { desc = '[S]earch [F]iles' })
set('n', '<leader>sgf', builtin.git_files, { desc = '[S]earch [G]it [F]iles' })
set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [H]elp' })
set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
set('n', '<leader>st', builtin.live_grep, { desc = '[S]earch by [T]ext' })
set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

-- file_browser extension
set("n", "<space>fb", function() require("telescope").extensions.file_browser.file_browser() end)
