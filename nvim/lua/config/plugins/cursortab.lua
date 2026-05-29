local uv = vim.uv

local M = {}
local state = {
    local_job = nil,
}

local function path_exists(path)
    return path and uv.fs_stat(path) ~= nil
end

local function executable(name)
    return vim.fn.executable(name) == 1
end

local function plugin_info()
    local plugins = vim.pack.get({ "cursortab.nvim" }, { info = false })
    return plugins and plugins[1] or nil
end

local function server_paths()
    local plugin = plugin_info()
    if not plugin then
        return nil, nil
    end

    local binary = "cursortab"
    if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        binary = binary .. ".exe"
    end

    local server_dir = vim.fs.joinpath(plugin.path, "server")
    return server_dir, vim.fs.joinpath(server_dir, binary)
end

function M.build(force)
    local server_dir, binary_path = server_paths()
    if not server_dir then
        return false, "cursortab.nvim is not installed yet"
    end

    if not force and path_exists(binary_path) then
        return true, binary_path
    end

    if not executable("go") then
        return false, "Go 1.25+ is required to build cursortab.nvim"
    end

    local result = vim.system({ "go", "build", "-o", vim.fs.basename(binary_path) }, {
        cwd = server_dir,
        text = true,
    }):wait()

    if result.code ~= 0 then
        local output = (result.stderr ~= "" and result.stderr) or result.stdout or "go build failed"
        return false, vim.trim(output)
    end

    return true, binary_path
end

local function normalize_provider(name)
    local provider = (name or ""):lower()
    if provider == "zeta2" then
        provider = "zeta-2"
    end
    if provider == "inline" or provider == "zeta-2" then
        return provider
    end
    return "inline"
end

local function is_local_provider(provider)
    return provider == "inline" or provider == "zeta-2"
end

local function local_model_spec(provider)
    if provider == "zeta-2" then
        return {
            kind = "hf",
            value = vim.env.CURSORTAB_ZETA_MODEL or "bartowski/zed-industries_zeta-2-GGUF:Q4_K_M",
            match = "zeta-2",
        }
    end

    return {
        kind = "hf",
        value = vim.env.CURSORTAB_INLINE_MODEL or "unsloth/Qwen3.5-0.8B-GGUF:Q4_K_M",
        match = "qwen3.5-0.8b",
    }
end

local function job_running(job)
    if not job then
        return false
    end
    return vim.fn.jobwait({ job }, 0)[1] == -1
end

local function current_server_model(callback)
    if not executable("curl") then
        callback(nil)
        return
    end

    vim.system({
        "curl",
        "-fsS",
        "--max-time",
        "1",
        "http://127.0.0.1:" .. tostring(vim.env.CURSORTAB_PORT or "8000") .. "/v1/models",
    }, { text = true }, function(result)
        if result.code ~= 0 then
            vim.schedule(function()
                callback(nil)
            end)
            return
        end

        local ok, decoded = pcall(vim.json.decode, result.stdout)
        local model = nil
        if ok and decoded then
            if decoded.models and decoded.models[1] and decoded.models[1].name then
                model = decoded.models[1].name
            elseif decoded.data and decoded.data[1] and decoded.data[1].id then
                model = decoded.data[1].id
            end
        end

        vim.schedule(function()
            callback(model)
        end)
    end)
end

local function port_has_llama_server(callback)
    vim.system({ "sh", "-lc", "ss -lptn 'sport = :" .. tostring(vim.env.CURSORTAB_PORT or "8000") .. "'" },
        { text = true }, function(result)
            local output = (result.stdout or "") .. (result.stderr or "")
            vim.schedule(function()
                callback(output:find("llama%-server") ~= nil)
            end)
        end)
end

local function stop_port_llama_server(callback)
    if not executable("fuser") then
        callback()
        return
    end

    vim.system({ "fuser", "-k", tostring(vim.env.CURSORTAB_PORT or "8000") .. "/tcp" }, { text = true }, function()
        vim.schedule(function()
            callback()
        end)
    end)
end

local function start_local_server(provider)
    if job_running(state.local_job) then
        return
    end

    local llama = vim.env.LLAMA_SERVER_BIN
    if not llama or llama == "" or not path_exists(llama) then
        local bundled = vim.fs.joinpath(vim.env.HOME, ".local", "share", "voxd", "bin", "llama-server")
        if path_exists(bundled) then
            llama = bundled
        else
            local exepath = vim.fn.exepath("llama-server")
            llama = exepath ~= "" and exepath or nil
        end
    end

    if not llama then
        return
    end

    local spec = local_model_spec(provider)
    local cmd = {
        llama,
        "--host", "127.0.0.1",
        "--port", tostring(vim.env.CURSORTAB_PORT or "8000"),
        "--threads", tostring(vim.env.CURSORTAB_THREADS or "4"),
        "--ctx-size", tostring(vim.env.CURSORTAB_CTX or "1024"),
        "--n-gpu-layers", "0",
    }

    if spec.kind == "hf" then
        vim.list_extend(cmd, { "-hf", spec.value })
    else
        vim.list_extend(cmd, { "-m", spec.value })
    end

    state.local_job = vim.fn.jobstart(cmd, {
        detach = false,
        on_exit = function()
            state.local_job = nil
        end,
    })
end

local function ensure_local_server(provider)
    provider = normalize_provider(provider)
    if not is_local_provider(provider) then
        return
    end

    local wanted = local_model_spec(provider)
    current_server_model(function(model)
        if not model then
            start_local_server(provider)
            return
        end

        local lower = model:lower()
        if lower:find(wanted.match, 1, true) then
            return
        end

        port_has_llama_server(function(is_llama)
            if not is_llama then
                return
            end
            stop_port_llama_server(function()
                vim.defer_fn(function()
                    start_local_server(provider)
                end, 150)
            end)
        end)
    end)
end

local function provider_config(provider)
    if provider == "zeta-2" then
        return {
            type = "zeta-2",
            url = "http://127.0.0.1:8000",
            max_tokens = 24,
            completion_timeout = 7000,
        }
    end

    return {
        type = "inline",
        url = "http://127.0.0.1:8000",
        context_size = 512,
        max_tokens = 8,
        completion_timeout = 6000,
    }
end

local function setup(provider_name)
    local provider = normalize_provider(provider_name)
    local ok, err = M.build(false)
    if not ok then
        vim.schedule(function()
            vim.notify("cursortab.nvim build failed: " .. err, vim.log.levels.WARN)
        end)
        return false
    end

    ensure_local_server(provider)

    local ok_cursortab, cursortab = pcall(require, "cursortab")
    if not ok_cursortab then
        vim.schedule(function()
            vim.notify("cursortab.nvim is not available", vim.log.levels.WARN)
        end)
        return false
    end

    cursortab.setup({
        log_level = "warn",
        keymaps = {
            accept = "<Tab>",
            partial_accept = false,
            trigger = false,
        },
        behavior = {
            idle_completion_delay = -1,
            text_change_debounce = 400,
            enabled_modes = { "insert" },
            cursor_prediction = {
                enabled = provider ~= "inline",
            },
            ignore_filetypes = { "", "terminal", "snacks_picker_input" },
        },
        provider = provider_config(provider),
    })

    vim.g.cursortab_provider = provider
    return true
end

vim.api.nvim_create_user_command("CursortabBuild", function()
    local ok, result = M.build(true)
    if ok then
        vim.notify("cursortab.nvim server built: " .. result, vim.log.levels.INFO)
    else
        vim.notify("cursortab.nvim build failed: " .. result, vim.log.levels.ERROR)
    end
end, { desc = "Build the cursortab.nvim Go server" })

vim.api.nvim_create_user_command("CursortabProvider", function(opts)
    local provider = normalize_provider(opts.args)
    if setup(provider) then
        vim.notify("cursortab provider: " .. provider, vim.log.levels.INFO)
    end
end, {
    nargs = 1,
    complete = function()
        return { "inline", "zeta-2" }
    end,
    desc = "Switch cursortab provider",
})

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local provider = normalize_provider(vim.g.cursortab_provider or vim.env.CURSORTAB_PROVIDER or "inline")
        vim.defer_fn(function()
            pcall(setup, provider)
        end, 50)
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        if job_running(state.local_job) then
            vim.fn.jobstop(state.local_job)
            state.local_job = nil
        end
    end,
})

return M
