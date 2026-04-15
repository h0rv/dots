local lint = require("lint")
local parser = require("lint.parser")
local project = require("config.project")

local function local_tool(name, bufnr)
    return project.local_executable(name, bufnr)
end

local function local_python(bufnr)
    return local_tool("python", bufnr)
end

local function has_lsp(name, bufnr)
    return #vim.lsp.get_clients({ bufnr = bufnr, name = name }) > 0
end

local function lint_cwd()
    return project.typecheck_root(0)
end

local function zig_cwd(bufnr)
    local file = vim.api.nvim_buf_get_name(bufnr)
    local dir = vim.fs.dirname(file)
    local root = vim.fs.find({ "build.zig", ".git" }, { path = dir, upward = true })[1]
    if root then
        return vim.fs.dirname(root)
    end
    return dir
end

local function zig_has_main(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for _, line in ipairs(lines) do
        if line:match("^%s*pub%s+fn%s+main%s*%(") or line:match("^%s*fn%s+main%s*%(") then
            return true
        end
    end
    return false
end

local function decode_github_data(value)
    if not value then
        return nil
    end

    return (value:gsub("%%0D", "\r"):gsub("%%0A", "\n"):gsub("%%25", "%%"))
end

local function decode_github_property(value)
    local decoded = decode_github_data(value)
    if not decoded then
        return nil
    end

    return (decoded:gsub("%%3A", ":"):gsub("%%2C", ","))
end

local function parse_github_kv(properties)
    local result = {}
    for key, value in properties:gmatch("([%w_]+)=([^,]*)") do
        result[key] = decode_github_property(value)
    end
    return result
end

local function ty_parser(output, bufnr, linter_cwd)
    local diagnostics = {}
    local current_file = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    local severity_map = {
        error = vim.diagnostic.severity.ERROR,
        warning = vim.diagnostic.severity.WARN,
        notice = vim.diagnostic.severity.INFO,
    }

    for line in vim.gsplit(output, "\n", true) do
        local severity, properties, message = line:match("^::(%a+)%s+(.-)::(.*)$")
        if severity and properties and message then
            local parsed = parse_github_kv(properties)
            local file = parsed.file
            if file then
                local absolute = file
                if not absolute:match("^%a:[/\\]") and not vim.startswith(absolute, "/") then
                    absolute = vim.fs.joinpath(linter_cwd, absolute)
                end

                if vim.fs.normalize(absolute) == current_file then
                    local title = parsed.title and decode_github_property(parsed.title) or nil
                    local code = title and title ~= "ty" and title or nil
                    local text = decode_github_data(message)
                    if code then
                        text = string.format("[%s] %s", code, text)
                    end

                    table.insert(diagnostics, {
                        lnum = math.max((tonumber(parsed.line) or 1) - 1, 0),
                        end_lnum = math.max((tonumber(parsed.endLine) or tonumber(parsed.line) or 1) - 1, 0),
                        col = math.max((tonumber(parsed.col) or 1) - 1, 0),
                        end_col = math.max((tonumber(parsed.endColumn) or tonumber(parsed.col) or 1) - 1, 0),
                        severity = severity_map[severity] or vim.diagnostic.severity.ERROR,
                        source = "ty",
                        message = text,
                        code = code,
                    })
                end
            end
        end
    end

    return diagnostics
end

if lint.linters.mypy then
    local mypy = lint.linters.mypy

    lint.linters.project_mypy = function()
        return vim.tbl_deep_extend("force", {}, mypy, {
            cmd = function() return local_tool("mypy", 0) end,
        })
    end

    lint.linters.project_dmypy = function()
        return vim.tbl_deep_extend("force", {}, mypy, {
            cmd = function() return local_tool("dmypy", 0) end,
            args = vim.list_extend({ "run", "--" }, vim.deepcopy(mypy.args or {})),
        })
    end
end

lint.linters.project_ty = {
    cmd = function() return local_tool("ty", 0) end,
    stdin = false,
    stream = "both",
    ignore_exitcode = true,
    args = {
        "check",
        "--output-format",
        "github",
        function()
            local python = local_python(0)
            return python and ("--python=" .. python) or nil
        end,
    },
    parser = ty_parser,
}

local python_typecheckers = { "project_ty", "project_dmypy", "project_mypy" }

local function available_python_typechecker(bufnr)
    if local_tool("ty", bufnr) and not has_lsp("ty", bufnr) then
        return "project_ty"
    end
    if local_tool("dmypy", bufnr) then
        return "project_dmypy"
    end
    if local_tool("mypy", bufnr) then
        return "project_mypy"
    end
    return nil
end

local function reset_python_typecheck_diagnostics(bufnr)
    for _, name in ipairs(python_typecheckers) do
        vim.diagnostic.reset(lint.get_namespace(name), bufnr)
    end
end

local function run_python_typecheck(bufnr)
    local linter = available_python_typechecker(bufnr)
    if not linter then
        reset_python_typecheck_diagnostics(bufnr)
        return
    end

    vim.api.nvim_buf_call(bufnr, function()
        lint.try_lint(linter, { cwd = lint_cwd() })
    end)
end

local zig_parser = parser.from_pattern(
    function(line)
        return { line:match("^(.-):(%d+):(%d+): (%a+): (.+)$") }
    end,
    { "file", "lnum", "col", "severity", "message" },
    {
        error = vim.diagnostic.severity.ERROR,
        warning = vim.diagnostic.severity.WARN,
        note = vim.diagnostic.severity.INFO,
    },
    { source = "zig" }
)

local zig_compile_ns = vim.api.nvim_create_namespace("zig_compile")

local function run_zig_compile(bufnr)
    local zig = vim.fn.exepath("zig")
    if zig == "" then
        vim.diagnostic.reset(zig_compile_ns, bufnr)
        return
    end

    local file = vim.api.nvim_buf_get_name(bufnr)
    if file == "" then
        vim.diagnostic.reset(zig_compile_ns, bufnr)
        return
    end

    local cwd = zig_cwd(bufnr)
    local cmd = zig_has_main(bufnr)
        and { zig, "build-exe", "-fno-emit-bin", file }
        or { zig, "test", file }

    local result = vim.system(cmd, { cwd = cwd, text = true }):wait()
    local output = table.concat(vim.tbl_filter(function(chunk)
        return chunk and chunk ~= ""
    end, { result.stderr, result.stdout }), "\n")

    local diagnostics = output ~= "" and zig_parser(output, bufnr, cwd) or {}
    vim.diagnostic.set(zig_compile_ns, bufnr, diagnostics)
end

local function run_current_typecheck(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft == "python" then
        run_python_typecheck(bufnr)
        return
    end
    if ft == "zig" then
        run_zig_compile(bufnr)
    end
end

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.py",
    callback = function(args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        if file:find("/%.venv/") then
            return
        end
        run_python_typecheck(args.buf)
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.zig",
    callback = function(args)
        run_zig_compile(args.buf)
    end,
})

vim.keymap.set("n", "<leader>ct", function()
    run_current_typecheck(0)
end, { desc = "Typecheck/compile now" })
