-- Key mappings configuration
-- All keybindings organized by category

local set = vim.keymap.set
local cmd = vim.cmd

-- ============================================================================
-- INSERT MODE KEYMAPS
-- ============================================================================

-- Escape from insert mode
set('i', 'jk', '<ESC>')
set('i', 'kj', '<ESC>')

-- ============================================================================
-- NORMAL MODE KEYMAPS
-- ============================================================================

-- File operations
set('n', '<leader>W', cmd.w, { desc = '[W]rite' })
set("n", "<leader>f", vim.lsp.buf.format, { desc = '[F]ormat' })

-- ============================================================================
-- WINDOW NAVIGATION
-- ============================================================================

set('n', '<leader>h', '<C-w>h', { desc = 'Move to left window' })
set('n', '<leader>j', '<C-w>j', { desc = 'Move to below window' })
set('n', '<leader>k', '<C-w>k', { desc = 'Move to above window' })
set('n', '<leader>l', '<C-w>l', { desc = 'Move to right window' })

-- ============================================================================
-- BUFFER NAVIGATION
-- ============================================================================

-- Helper function to get buffer list
local function get_buffer_list()
  local bufinfo = vim.fn.getbufinfo({ buflisted = 1 })
  local buffers = {}
  for _, info in ipairs(bufinfo) do
    table.insert(buffers, info.bufnr)
  end
  return buffers
end

-- Helper function to jump to buffer by index
local function goto_buffer(num)
  local buffers = get_buffer_list()
  if buffers[num] then
    cmd('buffer ' .. buffers[num])
  end
end

-- Tab/Shift-Tab for next/previous buffer (like browser tabs)
set('n', '<Tab>', function() 
  cmd('bnext') 
end, { desc = 'Next Buffer' })

set('n', '<S-Tab>', function() 
  cmd('bprevious') 
end, { desc = 'Previous Buffer' })

-- Numbered buffer switching - Method 1: Leader + number (easiest)
for i = 1, 9 do
  set('n', '<leader>' .. i, function()
    goto_buffer(i)
  end, { desc = 'Go to buffer ' .. i })
end

set('n', '<leader>0', function()
  goto_buffer(10)
end, { desc = 'Go to buffer 10' })

-- Numbered buffer switching - Method 2: Alt + number (like browser tabs)
for i = 1, 9 do
  set('n', '<A-' .. i .. '>', function()
    goto_buffer(i)
  end, { desc = 'Go to buffer ' .. i })
end

set('n', '<A-0>', function()
  goto_buffer(10)
end, { desc = 'Go to buffer 10' })

-- Numbered buffer switching - Method 3: g + number (traditional vim style)
for i = 1, 9 do
  set('n', 'g' .. i, function()
    goto_buffer(i)
  end, { desc = 'Go to buffer ' .. i })
end

set('n', 'g0', function()
  goto_buffer(10)
end, { desc = 'Go to buffer 10' })

-- Buffer management
set('n', '<leader>bd', function()
  local current = vim.fn.bufnr()
  local buffers = get_buffer_list()
  
  -- Find next buffer to switch to
  local next_buf = nil
  for i, bufnr in ipairs(buffers) do
    if bufnr == current then
      next_buf = buffers[i + 1] or buffers[i - 1]
      break
    end
  end
  
  -- Close current buffer
  cmd('bdelete ' .. current)
  
  -- Switch to next buffer if available
  if next_buf and vim.fn.bufexists(next_buf) == 1 then
    cmd('buffer ' .. next_buf)
  end
end, { desc = '[B]uffer [D]elete' })

set('n', '<leader>bD', function()
  cmd('bdelete!')
end, { desc = '[B]uffer [D]elete Force' })

set('n', '<leader>bb', function()
  cmd('buffers')
end, { desc = '[B]uffer [B]uffer List' })
