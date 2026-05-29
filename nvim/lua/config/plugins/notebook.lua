local M = {}

-- Keep notebook editing generic: kernels are chosen at runtime, not per project.
vim.g.molten_auto_open_output = false
vim.g.molten_output_win_max_height = 20
vim.g.molten_wrap_output = true
vim.g.molten_virt_text_output = true
-- For # %% files, keep output anchored to the last executed code line, not below the next cell marker.
vim.g.molten_virt_lines_off_by_1 = false
vim.g.molten_image_provider = "snacks.nvim"

pcall(function()
    require("jupytext").setup({
        style = "hydrogen",
        output_extension = "auto",
        force_ft = nil,
    })
end)

local function project_root()
    return vim.fs.root(0, { ".venv", "pyproject.toml", ".git" })
end

local function project_name(root)
    root = root or project_root()
    if not root then
        return nil
    end

    local pyproject = vim.fs.joinpath(root, "pyproject.toml")
    local lines = vim.fn.filereadable(pyproject) == 1 and vim.fn.readfile(pyproject) or {}
    local in_project = false

    for _, line in ipairs(lines) do
        if line:match("^%s*%[project%]%s*$") then
            in_project = true
        elseif line:match("^%s*%[") then
            in_project = false
        elseif in_project then
            local name = line:match('^%s*name%s*=%s*["\']([^"\']+)["\']')
            if name then
                return name
            end
        end
    end

    return nil
end

local function sanitize_kernel_name(name)
    return (name or "python")
        :lower()
        :gsub("[^%w_.-]+", "-")
        :gsub("^-+", "")
        :gsub("-+$", "")
end

local function project_python(root)
    for _, path in ipairs({
        vim.fs.joinpath(root, ".venv", "bin", "python"),
        vim.fs.joinpath(root, ".venv", "Scripts", "python.exe"),
    }) do
        if vim.fn.executable(path) == 1 then
            return path
        end
    end
    return nil
end

local function host_python()
    return vim.g.python3_host_prog or "python3"
end

local function python_has_ipykernel(python)
    local result = vim.system({ python, "-c", "import ipykernel" }, { text = true }):wait()
    return result.code == 0
end

local function kernelspec_matches(name, python)
    local script = [[
import sys
from jupyter_client.kernelspec import KernelSpecManager
name, python = sys.argv[1], sys.argv[2]
try:
    spec = KernelSpecManager().get_kernel_spec(name)
except Exception:
    raise SystemExit(1)
raise SystemExit(0 if spec.argv and spec.argv[0] == python else 1)
]]
    local result = vim.system({ host_python(), "-c", script, name, python }, { text = true }):wait()
    return result.code == 0
end

local function ensure_project_kernel()
    local root = project_root()
    if not root then
        return nil
    end

    local python = project_python(root)
    if not python then
        return nil
    end

    if not python_has_ipykernel(python) then
        vim.notify("Jupyter: project .venv is missing ipykernel", vim.log.levels.WARN)
        return nil
    end

    local display_name = project_name(root) or vim.fn.fnamemodify(root, ":t")
    local kernel = sanitize_kernel_name("local-" .. display_name)

    if kernelspec_matches(kernel, python) then
        return kernel
    end

    local result = vim.system({
        python,
        "-m",
        "ipykernel",
        "install",
        "--user",
        "--name",
        kernel,
        "--display-name",
        "Python (" .. display_name .. ")",
    }, { text = true }):wait()

    if result.code ~= 0 then
        vim.notify(result.stderr ~= "" and result.stderr or "Jupyter: failed to install project kernel", vim.log.levels.ERROR)
        return nil
    end

    return kernel
end

function M.init_kernel(kernel)
    if vim.b.jupyter_initialized then
        return true
    end

    kernel = kernel or vim.b.jupyter_kernel or vim.g.jupyter_kernel or ensure_project_kernel()
    local ok
    if not kernel or kernel == "" then
        vim.notify("Jupyter: no project kernel found; opening kernel picker", vim.log.levels.INFO)
        ok = pcall(vim.cmd, "MoltenInit")
    else
        vim.b.jupyter_kernel = kernel
        ok = pcall(vim.cmd, "MoltenInit " .. vim.fn.fnameescape(kernel))
    end

    vim.b.jupyter_initialized = ok
    return ok
end

local function ensure_kernel()
    if vim.b.jupyter_initialized then
        return true
    end
    return M.init_kernel()
end

local function normalize_cell_kind(kind)
    if kind == "markdown" or kind == "md" then
        return "markdown"
    elseif kind == "raw" then
        return "raw"
    end
    return "code"
end

local function cell_marker(kind)
    kind = normalize_cell_kind(kind)
    if kind == "markdown" then
        return "# %% [markdown]"
    elseif kind == "raw" then
        return "# %% [raw]"
    end
    return "# %%"
end

local function marker_kind(text)
    if text:match("%[markdown%]") then
        return "markdown"
    elseif text:match("%[raw%]") then
        return "raw"
    end
    return "code"
end

local function current_cell_marker_line()
    local cursor = vim.api.nvim_win_get_cursor(0)[1]

    for line = cursor, 1, -1 do
        local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
        if text:match("^%s*#%s*%%%%") then
            return line
        end
    end

    return nil
end

local function next_cell_marker_line(from)
    local last = vim.api.nvim_buf_line_count(0)
    for line = from + 1, last do
        local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
        if text:match("^%s*#%s*%%%%") then
            return line
        end
    end
    return nil
end

local function current_cell_kind()
    local marker = current_cell_marker_line()
    if not marker then
        return "code"
    end
    local text = vim.api.nvim_buf_get_lines(0, marker - 1, marker, false)[1] or "# %%"
    return marker_kind(text)
end

local function goto_next_cell()
    local next_cell = vim.fn.search([[^\s*#\s*%%]], "W")
    if next_cell > 0 then
        vim.api.nvim_win_set_cursor(0, { next_cell, 0 })
    end
end

local function trim_blank_bounds(start_line, end_line)
    while start_line <= end_line do
        local text = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1] or ""
        if text:match("%S") then
            break
        end
        start_line = start_line + 1
    end

    while end_line >= start_line do
        local text = vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1] or ""
        if text:match("%S") then
            break
        end
        end_line = end_line - 1
    end

    return start_line, math.max(start_line, end_line)
end

local function cell_bounds()
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local last = vim.api.nvim_buf_line_count(0)
    local marker = current_cell_marker_line()
    local next_marker = next_cell_marker_line(cursor)
    local start_line = marker and (marker + 1) or 1
    local end_line = next_marker and (next_marker - 1) or last

    return trim_blank_bounds(start_line, end_line)
end

local function transform_markdown_body(marker, to_markdown)
    local last = vim.api.nvim_buf_line_count(0)
    local next_marker = next_cell_marker_line(marker)
    local start_line = marker + 1
    local end_line = (next_marker and (next_marker - 1) or last)
    if start_line > end_line then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    for i, line in ipairs(lines) do
        if to_markdown then
            lines[i] = line == "" and "#" or (line:match("^%s*#") and line or ("# " .. line))
        else
            lines[i] = line:gsub("^# ?", "", 1)
        end
    end
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

function M.set_cell_type(kind)
    kind = normalize_cell_kind(kind)
    local marker = current_cell_marker_line()
    if not marker then
        vim.api.nvim_buf_set_lines(0, 0, 0, false, { cell_marker(kind), kind == "markdown" and "# " or "" })
        vim.api.nvim_win_set_cursor(0, { 2, kind == "markdown" and 2 or 0 })
        return
    end

    local old_marker = vim.api.nvim_buf_get_lines(0, marker - 1, marker, false)[1] or "# %%"
    local old_kind = marker_kind(old_marker)
    vim.api.nvim_buf_set_lines(0, marker - 1, marker, false, { cell_marker(kind) })

    if kind ~= "code" then
        pcall(vim.cmd, "silent! MoltenDelete")
    end

    if kind == "markdown" and old_kind ~= "markdown" then
        transform_markdown_body(marker, true)
    elseif kind ~= "markdown" and old_kind == "markdown" then
        transform_markdown_body(marker, false)
    end
end

function M.toggle_cell_type()
    local marker = current_cell_marker_line()
    if not marker then
        M.set_cell_type("code")
        return
    end

    local text = vim.api.nvim_buf_get_lines(0, marker - 1, marker, false)[1] or ""
    if text:match("%[markdown%]") then
        M.set_cell_type("code")
    else
        M.set_cell_type("markdown")
    end
end

function M.new_cell(kind, above)
    kind = normalize_cell_kind(kind)
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local marker = current_cell_marker_line()
    local insert_at

    if above then
        insert_at = (marker or cursor) - 1
    else
        local next_marker = marker and next_cell_marker_line(marker) or next_cell_marker_line(cursor)
        insert_at = next_marker and (next_marker - 1) or vim.api.nvim_buf_line_count(0)
    end

    local body = kind == "markdown" and "# " or ""
    local lines = above and { cell_marker(kind), body, "" } or { "", cell_marker(kind), body }
    vim.api.nvim_buf_set_lines(0, insert_at, insert_at, false, lines)
    vim.api.nvim_win_set_cursor(0, { insert_at + (above and 2 or 3), kind == "markdown" and 2 or 0 })
end

function M.run_cell(move_next)
    local kind = current_cell_kind()
    if kind ~= "code" then
        vim.notify("Jupyter: " .. kind .. " cells do not execute", vim.log.levels.INFO)
        if move_next then
            goto_next_cell()
        end
        return
    end

    if not ensure_kernel() then
        return
    end

    local start_line, end_line = cell_bounds()
    vim.fn.MoltenEvaluateRange(start_line, end_line)

    if move_next then
        goto_next_cell()
    end
end

function M.run_all()
    if not ensure_kernel() then
        return
    end

    local last = vim.api.nvim_buf_line_count(0)
    local line = 1
    local ran = 0

    while line <= last do
        local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
        if text:match("^%s*#%s*%%%%") and marker_kind(text) == "code" then
            local next_marker = next_cell_marker_line(line)
            local start_line = line + 1
            local end_line = next_marker and (next_marker - 1) or last

            start_line, end_line = trim_blank_bounds(start_line, end_line)

            if start_line <= end_line then
                vim.fn.MoltenEvaluateRange(start_line, end_line)
                ran = ran + 1
            end

            line = next_marker or (last + 1)
        else
            line = line + 1
        end
    end

    vim.notify("Jupyter: ran " .. ran .. " code cells")
end

function M.sync()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        vim.notify("No file to sync", vim.log.levels.WARN)
        return
    end

    vim.cmd.write()
    vim.system({ "jupytext", "--sync", file }, { text = true }, function(result)
        vim.schedule(function()
            if result.code == 0 then
                vim.notify("Jupyter: synced " .. vim.fn.fnamemodify(file, ":t"))
            else
                vim.notify(result.stderr ~= "" and result.stderr or "Jupytext sync failed", vim.log.levels.ERROR)
            end
        end)
    end)
end

vim.api.nvim_create_user_command("JupyterInit", function(opts)
    M.init_kernel(opts.args ~= "" and opts.args or nil)
end, { nargs = "?", complete = "shellcmd", desc = "Start/select a Jupyter kernel" })

vim.api.nvim_create_user_command("JupyterRunCell", function()
    M.run_cell(false)
end, { desc = "Run current # %% cell" })

vim.api.nvim_create_user_command("JupyterRunCellNext", function()
    M.run_cell(true)
end, { desc = "Run current # %% cell and jump to next" })

vim.api.nvim_create_user_command("JupyterRunAll", M.run_all, { desc = "Run all code cells" })

vim.api.nvim_create_user_command("JupyterSync", M.sync, { desc = "Sync paired Jupytext notebook" })
vim.api.nvim_create_user_command("JupyterCellCode", function() M.set_cell_type("code") end, { desc = "Set current cell to code" })
vim.api.nvim_create_user_command("JupyterCellMarkdown", function() M.set_cell_type("markdown") end, { desc = "Set current cell to markdown" })
vim.api.nvim_create_user_command("JupyterCellRaw", function() M.set_cell_type("raw") end, { desc = "Set current cell to raw" })
vim.api.nvim_create_user_command("JupyterCellToggle", M.toggle_cell_type, { desc = "Toggle current cell code/markdown" })
vim.api.nvim_create_user_command("JupyterNewCode", function() M.new_cell("code") end, { desc = "Insert code cell below" })
vim.api.nvim_create_user_command("JupyterNewCodeAbove", function() M.new_cell("code", true) end, { desc = "Insert code cell above" })
vim.api.nvim_create_user_command("JupyterNewMarkdown", function() M.new_cell("markdown") end, { desc = "Insert markdown cell below" })
vim.api.nvim_create_user_command("JupyterNewMarkdownAbove", function() M.new_cell("markdown", true) end, { desc = "Insert markdown cell above" })
vim.api.nvim_create_user_command("JupyterNewRaw", function() M.new_cell("raw") end, { desc = "Insert raw cell below" })
vim.api.nvim_create_user_command("JupyterNewRawAbove", function() M.new_cell("raw", true) end, { desc = "Insert raw cell above" })

local set = vim.keymap.set
set("n", "<leader>ji", M.init_kernel, { desc = "Jupyter: init kernel" })
set("n", "<leader>jc", function() M.run_cell(false) end, { desc = "Jupyter: run cell" })
set("n", "<leader>jj", function() M.run_cell(true) end, { desc = "Jupyter: run cell + next" })
set("n", "<leader>ja", M.run_all, { desc = "Jupyter: run all code cells" })
set("n", "<leader>jl", function()
    if current_cell_kind() ~= "code" then
        vim.notify("Jupyter: " .. current_cell_kind() .. " cells do not execute", vim.log.levels.INFO)
        return
    end
    if not ensure_kernel() then
        return
    end
    vim.cmd.MoltenEvaluateLine()
end, { desc = "Jupyter: run line" })
set("v", "<leader>jr", ":<c-u>MoltenEvaluateVisual<cr>", { desc = "Jupyter: run selection" })
set("n", "<leader>jp", "<cmd>MoltenShowOutput<cr>", { desc = "Jupyter: show output" })
set("n", "<leader>jh", "<cmd>MoltenHideOutput<cr>", { desc = "Jupyter: hide output" })
set("n", "<leader>jd", "<cmd>MoltenDelete<cr>", { desc = "Jupyter: delete output" })
set("n", "<leader>jk", "<cmd>MoltenInterrupt<cr>", { desc = "Jupyter: interrupt" })
set("n", "<leader>jR", "<cmd>MoltenRestart<cr>", { desc = "Jupyter: restart kernel" })
set("n", "<leader>js", M.sync, { desc = "Jupyter: sync jupytext" })
set("n", "<leader>jo", function() M.new_cell("code") end, { desc = "Jupyter: new code cell below" })
set("n", "<leader>jO", function() M.new_cell("code", true) end, { desc = "Jupyter: new code cell above" })
set("n", "<leader>jn", function() M.new_cell("code") end, { desc = "Jupyter: new code cell below" })
set("n", "<leader>jm", function() M.new_cell("markdown") end, { desc = "Jupyter: new markdown cell below" })
set("n", "<leader>jM", function() M.new_cell("markdown", true) end, { desc = "Jupyter: new markdown cell above" })
set("n", "<leader>jx", function() M.new_cell("raw") end, { desc = "Jupyter: new raw cell below" })
set("n", "<leader>jX", function() M.new_cell("raw", true) end, { desc = "Jupyter: new raw cell above" })
set("n", "<leader>jt", M.toggle_cell_type, { desc = "Jupyter: toggle code/markdown" })
set("n", "<leader>jC", function() M.set_cell_type("code") end, { desc = "Jupyter: cell type code" })

return M
