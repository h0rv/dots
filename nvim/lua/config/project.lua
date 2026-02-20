local uv = vim.uv

local function path_exists(p)
    return p and uv.fs_stat(p) ~= nil
end

-- Find project root (git > pyproject.toml)
local function project_root(bufnr)
    bufnr = bufnr or 0
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return uv.cwd()
    end

    local dir = vim.fs.dirname(name)

    local git = vim.fs.find(".git", { path = dir, upward = true })[1]
    if git then
        return vim.fs.dirname(git)
    end

    local pyproject = vim.fs.find("pyproject.toml", { path = dir, upward = true })[1]
    if pyproject then
        return vim.fs.dirname(pyproject)
    end

    return uv.cwd()
end

local active_venv = nil

local function activate_venv(root)
    local venv = root .. "/.venv"
    local venv_bin = venv .. "/bin"

    if not path_exists(venv_bin) then
        return
    end

    -- Avoid re-activating the same venv
    if active_venv == venv then
        return
    end
    active_venv = venv

    -- Set VIRTUAL_ENV (many tools rely on this)
    vim.env.VIRTUAL_ENV = venv

    -- Prepend venv/bin to PATH (deduplicated)
    local sep = ":"
    local path = vim.env.PATH or ""
    local parts = vim.split(path, sep, { plain = true })

    local new = { venv_bin }
    for _, p in ipairs(parts) do
        if p ~= venv_bin then
            table.insert(new, p)
        end
    end

    vim.env.PATH = table.concat(new, sep)

    -- Optional: useful confirmation (comment out if you want it silent)
    -- vim.notify("Activated venv: " .. venv, vim.log.levels.DEBUG)
end

-- Activate venv at startup for the initial cwd (before LSPs start)
activate_venv(uv.cwd())

-- Activate venv when entering buffers (handles switching projects)
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
            return
        end
        local root = project_root(args.buf)
        activate_venv(root)
    end,
})

-- Export project_root for use in other modules
return {
    project_root = project_root,
}
