-- Key mappings configuration

local set = vim.keymap.set
local cmd = vim.cmd

-- Escape from insert mode
set('i', 'jk', '<ESC>')
set('i', 'kj', '<ESC>')

-- File operations
set('n', '<leader>w', cmd.w, { desc = 'Write' })
set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format' })

-- Buffer navigation
local function get_buffer_list()
    local bufinfo = vim.fn.getbufinfo({ buflisted = 1 })
    local buffers = {}
    for _, info in ipairs(bufinfo) do
        table.insert(buffers, info.bufnr)
    end
    return buffers
end

local function goto_buffer(num)
    local buffers = get_buffer_list()
    if buffers[num] then
        cmd('buffer ' .. buffers[num])
    end
end

-- Tab/Shift-Tab for next/previous buffer
set('n', '<Tab>', cmd.bnext, { desc = 'Next buffer' })
set('n', '<S-Tab>', cmd.bprevious, { desc = 'Previous buffer' })

-- Leader + number for buffer switching
for i = 1, 9 do
    set('n', '<leader>' .. i, function()
        goto_buffer(i)
    end, { desc = 'Buffer ' .. i })
end

set('n', '<leader>0', function()
    goto_buffer(10)
end, { desc = 'Buffer 10' })
