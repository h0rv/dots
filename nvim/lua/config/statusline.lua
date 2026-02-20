-- Minimal statusline matching tokyonight tmux bar
-- Shows: mode | file [modified] | diagnostics ... line:col

local modes = {
    n = "NOR", i = "INS", v = "VIS", V = "V-L", ["\22"] = "V-B",
    c = "CMD", R = "REP", s = "SEL", S = "S-L", t = "TER",
}

function _G.MyStatusLine()
    local mode = vim.fn.mode()
    local mode_str = modes[mode] or mode:upper()

    -- File
    local name = vim.fn.expand("%:t")
    if name == "" then name = "[No Name]" end
    local modified = vim.bo.modified and " +" or ""

    -- Diagnostics
    local diag = ""
    local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    if err > 0 then diag = diag .. " " .. err end
    if warn > 0 then diag = diag .. " " .. warn end

    -- Position
    local pos = vim.fn.line(".") .. ":" .. vim.fn.col(".")

    return " " .. mode_str .. "  " .. name .. modified .. "%=" .. diag .. "  " .. pos .. " "
end

vim.opt.laststatus = 2
vim.opt.statusline = "%!v:lua.MyStatusLine()"
