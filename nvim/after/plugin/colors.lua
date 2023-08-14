require('catppuccin').setup({
    flavour = 'mocha', -- latte, frappe, macchiato, mocha
    background = {   -- :h background
        light = 'latte',
        dark = 'mocha',
    },
    transparent_background = false,
    show_end_of_buffer = false, -- show the '~' characters after the end of buffers
    term_colors = false,
    dim_inactive = {
        enabled = false,
        shade = 'dark',
        percentage = 0.15,
    },
    no_italic = true, -- Force no italic
    no_bold = false, -- Force no bold
    styles = {
        comments = { 'italic' },
        conditionals = { 'italic' },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
    },
    color_overrides = {},
    custom_highlights = {},
    integrations = {
        alpha = true,
        cmp = true,
        dap = {
            enabled = true,
            enable_ui = true, -- enable nvim-dap-ui
        },
        nvimtree = true,
        telescope = {
            enabled = true,
            style = "nvchad"
        },
        mason = true,
        markdown = true,
        which_key = true,
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

-- setup must be called before loading
-- vim.cmd.colorscheme 'catppuccin'
vim.cmd.colorscheme 'everblush'
