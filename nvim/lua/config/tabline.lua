-- Custom tabline function to show buffers like VSCode/browser tabs
-- Based on: https://github.com/neovim/neovim/discussions/24131
-- and https://stackoverflow.com/questions/33710069/how-to-write-tabline-function-in-vim

local opt = vim.opt

-- Custom tabline function
function _G.MyTabLine()
  local s = ""
  local current_buf = vim.fn.bufnr()
  
  -- Get all listed buffers using modern API
  local bufinfo = vim.fn.getbufinfo({ buflisted = 1 })
  
  for idx, info in ipairs(bufinfo) do
    local bufnr = info.bufnr
    
    -- Add separator between buffers
    if idx > 1 then
      s = s .. " "
    end
    
    -- Highlight current buffer differently
    if bufnr == current_buf then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end
    
    -- Set buffer number for mouse clicks (left click to switch to buffer)
    -- Format: %{number}T makes that area clickable
    s = s .. "%" .. bufnr .. "T"
    
    -- Buffer index number (1-based for display, matches g1-g9 keybindings)
    s = s .. " " .. idx .. ":"
    
    -- Get buffer name
    local name = info.name
    if name == "" then
      name = "[No Name]"
    else
      name = vim.fn.fnamemodify(name, ":t")
    end
    
    -- Truncate long names (max 25 chars)
    if #name > 25 then
      name = name:sub(1, 22) .. "..."
    end
    
    s = s .. name
    
    -- Show modified indicator
    if info.changed == 1 then
      s = s .. " +"
    end
    
    s = s .. " "
  end
  
  -- Fill remaining space
  s = s .. "%#TabLineFill#%T"
  
  return s
end

-- Set the custom tabline
-- Clear any old tabline first to avoid cached function references
opt.tabline = ""
vim.cmd("redrawtabline")
opt.tabline = "%!v:lua.MyTabLine()"
