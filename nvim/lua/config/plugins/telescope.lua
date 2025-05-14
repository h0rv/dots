return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()
            require('telescope').setup {
                defaults = {},
                pickers = {
                    find_files = {
                        theme = "ivy",
                    },
                    live_grep = {
                        theme = "ivy",
                    },
                    help_tags = {
                        theme = "ivy",
                    },
                },
                extensions = {},
            }

            require('telescope').load_extension('fzf')

            -- search files in cwd
            vim.keymap.set("n", "<leader>sf", require('telescope.builtin').find_files)
            -- search files in cwd
            vim.keymap.set("n", "<leader>st", require('telescope.builtin').live_grep)
            -- search neovim config files
            vim.keymap.set("n", "<leader>sn", function()
                require('telescope.builtin').find_files {
                    cwd = vim.fn.stdpath('config')
                }
            end)
            -- search help
            vim.keymap.set("n", "<leader>sh", require('telescope.builtin').help_tags)
        end
    }
}
