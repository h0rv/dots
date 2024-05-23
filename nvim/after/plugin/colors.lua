require('catppuccin').setup({
    flavour = 'mocha', -- latte, frappe, macchiato, mocha
    background = {     -- :h background
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
    no_bold = false,  -- Force no bold
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

-- vim.cmd.colorscheme 'noirbuddy'
--
-- require('noirbuddy').setup({
--     -- preset = 'minimal',
--     -- preset = 'miami-nights',
--     preset = 'slate',
--     -- preset = 'kiwi',
--     -- preset = 'crt-green',
--     -- preset = 'crt-amber',
--     -- preset = 'christmas',
-- })
--
--
-- setup must be called before loading

-- vim.cmd.colorscheme 'catppuccin'
-- local mocha = require("catppuccin.palettes").get_palette "mocha"
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = mocha.green, cterm = bold, bold = true, }) -- Set current line number color and text style

-- vim.cmd.colorscheme 'everblush'
-- local everblush = require("everblush.palette")
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = everblush.color5, cterm = bold, bold = false, }) -- Set current line number color and text style

-- require 'nordic'.load()

vim.cmd.colorscheme 'deepwhite'
require('deepwhite').setup({
    -- If you have some anti-blue light setting (f.lux, light bulb, or low blue light mode monitor),
    -- turn it on, this will set the background color to a cooler color to prevent the background from being too warm.
    low_blue_light = true
})
-- for lualine
require('lualine').setup({
        options = {
            theme = 'deepwhite',
        },
    })
-- for barbar
require('barbar').setup({
        icons = {
            filetype = {
                custom_colors = true,
            },
        },
})
