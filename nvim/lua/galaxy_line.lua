local gl = require('galaxyline')
local color = require('xresources')

local gls = gl.section
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

-- gls.right[8] = {
--     FileFormat = {
--         provider = function() return ' ' .. vim.bo.filetype end,
--         highlight = {colors.fg, colors.section_bg},
--         separator = '',
--         separator_highlight = {colors.section_bg, colors.bg}
--     }
-- }


gls.short_line_left[1] = {
   BufferType = {
      provider = {function() return '    ' end, 'FileTypeName', function() return ' ' end, },
      highlight = {colors.bg, colors.blue},
      separator = '  ',
      separator_highlight = {colors.gray, colors.gray}
   }
}

gl.load_galaxyline()
