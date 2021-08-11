-- general
lvim.format_on_save = false
lvim.lint_on_save = true
lvim.colorscheme = "xresources"
vim.opt.scrolloff = 8 
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
lvim.builtin.terminal.shell = "/bin/fish"


-- compile and open zathura
vim.cmd([[
  " Call compile
  " Open the PDF from /tmp/"
  function! Preview()
      :call Compile()<CR><CR>
      execute "! zathura /tmp/op.pdf &"
  endfunction

  " [1] Get the extension of the file
  " [2] Apply appropriate compilation command
  " [3] Save PDF as /tmp/op.pdf
  function! Compile()
      let extension = expand('%:e')
      if extension == "md"
          execute "! pandoc '%:p' -s -V geometry:margin=.25in -o /tmp/op.pdf"
      elseif extension == "tex"
          execute "! pandoc -f latex -t latex % -o /tmp/op.pdf"
      endif
  endfunction

  " \ + q: Compile
  noremap <A-p> :call Preview()<CR><CR><CR>
  " \ + p: Preview
  noremap <A-c> :call Compile()<CR><CR>
]])

-- keymappings
lvim.leader = "space"
-- overwrite the key-mappings provided by LunarVim for any mode, or leave it empty to keep them
lvim.keys.normal_mode = {

}
-- if you just want to augment the existing ones then use the utility function
-- require("utils").add_keymap_insert_mode({ silent = true }, {
-- { "<C-s>", ":w<cr>" },
-- { "<C-c>", "<ESC>" },
-- })
-- you can also use the native vim way directly
-- vim.api.nvim_set_keymap("i", "<C-Space>", "compe#complete()", { noremap = true, silent = true, expr = true })

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.galaxyline.active = true
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.gitsigns.active = false
lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0
-- Configure icons on the bufferline.
lvim.builtin.bufferline = {
  icon_separator_active = ' ',
  icon_separator_inactive = ' ',
  icon_close_tab = ' ',
  icon_close_tab_modified = '●',
}

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {}
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings
-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- Additional Plugins
lvim.plugins = {
    {"folke/tokyonight.nvim"}, {
        "ray-x/lsp_signature.nvim",
        config = function() require"lsp_signature".on_attach() end,
        event = "InsertEnter"
    },
    {"nekonako/xresources-nvim"},
    {"andweeb/presence.nvim"},
    { 'iamcco/markdown-preview.nvim',
      ft = 'markdown',
      run = 'cd app && yarn install'
    },
    {"Shadorain/shadotheme"},
    {"folke/zen-mode.nvim",
        config = function()
            require("zen-mode").setup {
                backdrop = 1.0,
                kitty = {
                  enabled = true,
                  font = "+2", -- font size increment
                },
            }
        end
    },
    {"folke/twilight.nvim"},
    {"sonph/onehalf",
        rtp = "vim" },
    {"norcalli/nvim-colorizer.lua"},
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
lvim.autocommands.custom_groups = {
  { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
}

-- GalaxyLine
if lvim.colorscheme == "xresources" then
    lvim.builtin.galaxyline.on_config_done = function(gl)

        local gl = require('galaxyline')
        local color = require('xresources')

        local gls = gl.section
        -- remove lvim's default line
        count = #gls.right
        for i=0, count do gls.right[i]=nil end
        count = #gls.left
        for i=0, count do gls.left[i]=nil end
        gl.short_line_list = {'defx', 'packager', 'vista', 'NvimTree'}

        local colors = {
           bg = color.bg,
           fg = color.fg,
           red = color.red,
           green = color.green,
           yellow = color.yellow,
           blue = color.blue,
           purple = color.purple,
           cyan = color.cyan,
           gray = color.grey
        }

        local mode_color = function()
           local mode_colors = {
              n = colors.red,
              i = colors.purple,
              c = colors.purple,
              V = colors.yellow,
              [''] = colors.yellow,
              v = colors.yellow,
              R = colors.red1,
              t = colors.blue
           }

           if mode_colors[vim.fn.mode()] ~= nil then
              return mode_colors[vim.fn.mode()]
           else
              print(vim.fn.mode())
              return colors.purple
           end
        end

        local function file_readonly()
           if vim.bo.filetype == 'help' then return '' end
           if vim.bo.readonly == true then return '  ' end
           return ''
        end

        local function get_current_file_name()
           local file = vim.fn.expand('%:t')
           if vim.fn.empty(file) == 1 then return '' end
           if string.len(file_readonly()) ~= 0 then return file .. file_readonly() end
           -- if vim.bo.modifiable then
           --     if vim.bo.modified then return file .. '  ' end
           -- end
           return file .. ' '
        end

        -- Left side
        gls.left[1] = {
           ViMode = {
              provider = function()
                 local alias = {
                    n = 'NORMAL',
                    i = 'INSERT',
                    c = 'COMMAND',
                    v = 'VISUAL',
                    V = 'V-LINE',
                    [''] = 'VISUAL',
                    R = 'REPLACE',
                    t = 'TERMINAL',
                    s = 'SELECT',
                    S = 'S-LINE'
                 }
                 vim.api.nvim_command('hi GalaxyViMode guibg=' .. mode_color())
                 if alias[vim.fn.mode()] ~= nil then
                    return '  ' .. alias[vim.fn.mode()] .. ' '
                 else
                    return '  V-BLOCK '
                 end
              end,
              highlight = {colors.bg, colors.bg}
           }
        }
        gls.left[9] = {
           DiagnosticError = {
              provider = 'DiagnosticError',
              icon = '  ',
              highlight = {colors.red, colors.gray}
           }
        }
        gls.left[10] = {
           Space = {
              provider = function() return ' ' end,
              highlight = {colors.fg, colors.gray}
           }
        }
        gls.left[11] = {
           DiagnosticWarn = {
              provider = 'DiagnosticWarn',
              icon = '  ',
              highlight = {colors.yellow, colors.gray}
           }
        }
        gls.left[12] = {
           Space = {
              provider = function() return ' ' end,
              highlight = {colors.fg, colors.gray}
           }
        }
        gls.left[13] = {
           DiagnosticInfo = {
              provider = 'DiagnosticInfo',
              icon = '  ',
              highlight = {colors.yellow, colors.gray},
              separator = ' ',
              separator_highlight = {colors.gray, colors.gray}
           }
        }

        -- Right side
        gls.right[1] = {
           PerCent = {
              provider =  {function() return '  ' end, 'LinePercent', function() return ' ' end,},
              -- separator = ' ',
              -- separator_highlight = {colors.bg, colors.blue},
              highlight = {colors.bg, colors.blue}
           }
        }

        gls.short_line_left[1] = {
           BufferType = {
              provider = {function() return '    ' end, 'FileTypeName', function() return ' ' end, },
              highlight = {colors.bg, colors.blue},
              separator = '  ',
              separator_highlight = {colors.gray, colors.gray}
           }
        }

    end
end

-- tab complete bindings
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn['vsnip#available'](1) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn['vsnip#jumpable'](-1) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

