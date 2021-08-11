--[[
O is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]

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
          execute "! pandoc '%:p' -s -V geometry:margin=.1in -o /tmp/op.pdf"
      elseif extension == "tex"
          execute "! pandoc -f latex -t latex % -o /tmp/op.pdf"
      endif
  endfunction

  " \ + q: Compile
  noremap <A-p> :call Preview()<CR><CR><CR>
  " \ + p: Preview
  noremap <A-c> :call Compile()<CR><CR>
]])

-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
-- general
O.shift_width = 4
O.tab_stop = 4
O.scrolloff = 8
O.colorcolumn = "0" -- fixes indentline for now
O.format_on_save = false
O.auto_complete = true
O.coloscheme = "xresources"
O.auto_close_tree = 0
O.wrap_lines = true
O.timeoutlen = 100
O.leader_key = " "
O.ignore_case = true
O.smart_case = true

-- TODO User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
O.plugin.dashboard.active = true
O.plugin.colorizer.active = false
O.plugin.ts_playground.active = false
O.plugin.indent_line.active = true
O.plugin.zen.active = true

-- dashboard
-- O.dashboard.custom_header = {""}
-- O.dashboard.footer = {""}

-- if you don't want all the parsers change this to a table of the ones you want
O.treesitter.ensure_installed = "maintained"
O.treesitter.ignore_install = { "haskell" }
O.treesitter.highlight.enabled = true

-- python
-- O.python.linter = 'flake8'
O.lang.python.isort = true
O.lang.python.diagnostics.virtual_text = true
O.lang.python.analysis.use_library_code_types = true

-- javascript
O.lang.tsserver.linter = nil

-- Additional Plugins
O.user_plugins = {
  {"nekonako/xresources-nvim"},
  {"folke/twilight.nvim"},
  {"andweeb/presence.nvim"},
  { 'iamcco/markdown-preview.nvim',
    ft = 'markdown',
    run = 'cd app && yarn install'
  },
  {"Shadorain/shadotheme"},
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- O.user_autocommands = {{ "BufWinEnter", "*", "echo \"hi again\""}}

-- Additional Leader bindings for WhichKey
-- O.user_which_key = {
--   A = {
--     name = "+Custom Leader Keys",
--     a = { "<cmd>echo 'first custom command'<cr>", "Description for a" },
--     b = { "<cmd>echo 'second custom command'<cr>", "Description for b" },
--   },
-- }
