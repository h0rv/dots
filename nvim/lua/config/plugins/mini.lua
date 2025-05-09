return {
    {
        'echasnovski/mini.nvim',
        version = '*',
        config = function()
            require('mini.statusline').setup {
                use_icons = true,
            }
            require('mini.files').setup {
                -- General options
                options = {
                    permanent_delete = false,
                    use_as_default_explorer = true,
                },
            }
        end
    }
}
