local uv = vim.uv

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local env_sep = is_windows and ";" or ":"
local bin_dir_name = is_windows and "Scripts" or "bin"
local exe_suffix = is_windows and ".exe" or ""

local base_path = vim.env.PATH or ""
local base_virtual_env = vim.env.VIRTUAL_ENV

local M = {}

local PYTHON_WORKSPACE_MARKERS = {
    "pyrightconfig.json",
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
    "uv.lock",
    "setup.py",
    "setup.cfg",
    "tox.ini",
    "requirements.txt",
}

local PYTHON_TYPECHECK_MARKERS = {
    "ty.toml",
    "mypy.ini",
    "pyrightconfig.json",
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
    "uv.lock",
    "setup.py",
    "setup.cfg",
    "tox.ini",
    "requirements.txt",
}

local function path_exists(path)
    return path and uv.fs_stat(path) ~= nil
end

local function is_directory(path)
    local stat = path and uv.fs_stat(path)
    return stat and stat.type == "directory" or false
end

local function normalize(path)
    return path and vim.fs.normalize(path) or nil
end

local function source_dir(source)
    if type(source) == "number" then
        local name = vim.api.nvim_buf_get_name(source)
        if name == "" then
            return uv.cwd()
        end
        return normalize(vim.fs.dirname(name))
    end

    if type(source) == "string" and source ~= "" then
        if is_directory(source) then
            return normalize(source)
        end
        return normalize(vim.fs.dirname(source))
    end

    return uv.cwd()
end

local function search_upwards(start_dir, stop_dir, predicate)
    local dir = normalize(start_dir)
    local limit = normalize(stop_dir)

    while dir do
        local result = predicate(dir)
        if result then
            return result
        end

        if limit and dir == limit then
            break
        end

        local parent = vim.fs.dirname(dir)
        if not parent or parent == dir then
            break
        end
        dir = parent
    end
end

local function find_nearest_marker_dir(start_dir, markers, stop_dir)
    return search_upwards(start_dir, stop_dir, function(dir)
        for _, marker in ipairs(markers) do
            local names = type(marker) == "table" and marker or { marker }
            for _, name in ipairs(names) do
                if path_exists(vim.fs.joinpath(dir, name)) then
                    return dir
                end
            end
        end
    end)
end

local function find_venv(start_dir, stop_dir)
    return search_upwards(start_dir, stop_dir, function(dir)
        local venv = vim.fs.joinpath(dir, ".venv")
        if is_directory(venv) then
            return normalize(venv)
        end
    end)
end

local function executable_name(name)
    if exe_suffix ~= "" and not name:match(vim.pesc(exe_suffix) .. "$") then
        return name .. exe_suffix
    end
    return name
end

local function venv_executable(info, name)
    if not info.venv then
        return nil
    end

    local candidate = vim.fs.joinpath(info.venv, bin_dir_name, executable_name(name))
    if path_exists(candidate) then
        return candidate
    end

    return nil
end

function M.python_workspace(source)
    local start_dir = source_dir(source)
    local git_root = find_nearest_marker_dir(start_dir, { ".git" })
    local config_root = find_nearest_marker_dir(start_dir, PYTHON_WORKSPACE_MARKERS, git_root)
    local root = config_root or git_root or start_dir or uv.cwd()
    local search_limit = git_root or root

    return {
        start_dir = start_dir,
        root = root,
        git_root = git_root,
        config_root = config_root,
        venv = find_venv(start_dir, search_limit),
    }
end

function M.project_root(source)
    return M.python_workspace(source).root
end

function M.typecheck_root(source)
    local start_dir = source_dir(source)
    local git_root = find_nearest_marker_dir(start_dir, { ".git" })
    local config_root = find_nearest_marker_dir(start_dir, PYTHON_TYPECHECK_MARKERS, git_root)

    return config_root or git_root or start_dir or uv.cwd()
end

function M.basedpyright_config_root(source)
    local start_dir = source_dir(source)
    local git_root = find_nearest_marker_dir(start_dir, { ".git" })
    local root = find_nearest_marker_dir(start_dir, { "pyrightconfig.json", "pyproject.toml" }, git_root)
    if not root then
        return nil
    end

    if path_exists(vim.fs.joinpath(root, "pyrightconfig.json")) or path_exists(vim.fs.joinpath(root, "pyproject.toml")) then
        return root
    end

    return nil
end

function M.basedpyright_config_path(source)
    local root = M.basedpyright_config_root(source)
    if not root then
        return nil
    end

    local pyrightconfig = vim.fs.joinpath(root, "pyrightconfig.json")
    if path_exists(pyrightconfig) then
        return pyrightconfig
    end

    local pyproject = vim.fs.joinpath(root, "pyproject.toml")
    if path_exists(pyproject) then
        return pyproject
    end

    return nil
end

function M.resolve_executable(name, source)
    local info = M.python_workspace(source)
    local candidate = venv_executable(info, name)
    if candidate then
        return candidate
    end

    local exepath = vim.fn.exepath(name)
    if exepath ~= "" then
        return exepath
    end

    return name
end

function M.local_executable(name, source)
    return venv_executable(M.python_workspace(source), name)
end

function M.python_path(source)
    return M.resolve_executable("python", source)
end

function M.command_env(source)
    local info = M.python_workspace(source)
    if info.venv then
        return {
            PATH = table.concat({ vim.fs.joinpath(info.venv, bin_dir_name), base_path }, env_sep),
            VIRTUAL_ENV = info.venv,
        }
    end

    local env = { PATH = base_path }
    if base_virtual_env then
        env.VIRTUAL_ENV = base_virtual_env
    end
    return env
end

vim.api.nvim_create_user_command("PythonLspInfo", function(opts)
    local source = opts.args ~= "" and opts.args or 0
    local info = M.python_workspace(source)
    local lines = {
        "root: " .. info.root,
        "typecheck root: " .. M.typecheck_root(source),
        "config root: " .. (info.config_root or "none"),
        "git root: " .. (info.git_root or "none"),
        "venv: " .. (info.venv or "none"),
        "python: " .. M.python_path(source),
        "ruff: " .. M.resolve_executable("ruff", source),
        "basedpyright: " .. M.resolve_executable("basedpyright-langserver", source),
        "ty: " .. (M.local_executable("ty", source) or "none"),
        "dmypy: " .. (M.local_executable("dmypy", source) or "none"),
        "mypy: " .. (M.local_executable("mypy", source) or "none"),
    }

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Python LSP" })
end, { nargs = "?", complete = "file", desc = "Show resolved Python LSP paths" })

return M
