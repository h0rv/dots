-- nvim/lua/config/plugins/cursor-tab.lua

local uv = vim.uv or vim.loop

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO)
  end)
end

local function path_join(...)
  return table.concat({ ... }, "/")
end

local function file_exists(p)
  return uv.fs_stat(p) ~= nil
end

local function dir_exists(p)
  local st = uv.fs_stat(p)
  return st and st.type == "directory" or false
end

local function is_executable(p)
  return vim.fn.executable(p) == 1
end

local function run(cmd, opts)
  opts = opts or {}
  local res = vim.system(cmd, { cwd = opts.cwd, text = true }):wait()
  return res
end

-- ---------------------------------------------------------------------------
-- Paths (purely relative to stdpath("config"))
-- ---------------------------------------------------------------------------

local CONFIG = vim.fn.stdpath("config") -- ~/.config/nvim (symlinked to repo/nvim)

local CURSORTAB = {
  root = path_join(CONFIG, "pack", "core", "start", "cursortab.nvim"),
}

local SERVER = {
  dir = path_join(CURSORTAB.root, "server"),
  bin = path_join(CURSORTAB.root, "server", "cursortab"),
}

-- ---------------------------------------------------------------------------
-- 1) Ensure cursortab.nvim is present (submodule sanity check)
-- ---------------------------------------------------------------------------

local function ensure_cursortab_present()
  local entry = path_join(CURSORTAB.root, "lua", "cursortab", "init.lua")
  if dir_exists(CURSORTAB.root) and file_exists(entry) then
    return true
  end

  notify("cursortab.nvim not found under pack/core/start — did you init submodules?", vim.log.levels.ERROR)
  return false
end

-- ---------------------------------------------------------------------------
-- 2) Ensure cursortab server is built
-- ---------------------------------------------------------------------------

local function ensure_cursortab_server_built()
  if file_exists(SERVER.bin) and is_executable(SERVER.bin) then
    return true
  end

  if vim.fn.executable("go") ~= 1 then
    notify("Go is not available; cannot build cursortab server.", vim.log.levels.ERROR)
    return false
  end

  notify("Building cursortab server…")
  local res = run({ "go", "build", "-o", "cursortab", "." }, { cwd = SERVER.dir })

  if res.code ~= 0 then
    notify(("go build failed:\n%s"):format(res.stderr or res.stdout or ""), vim.log.levels.ERROR)
    return false
  end

  notify("cursortab server built ✓")
  return true
end

-- ---------------------------------------------------------------------------
-- 3) Ensure llama-server is running (reuse if already running)
-- ---------------------------------------------------------------------------

local function is_listening(host, port, timeout_ms, cb)
  timeout_ms = timeout_ms or 150
  local tcp = uv.new_tcp()
  local done = false
  local timer = uv.new_timer()

  timer:start(timeout_ms, 0, function()
    if done then return end
    done = true
    pcall(timer.stop, timer); pcall(timer.close, timer)
    pcall(tcp.close, tcp)
    cb(false)
  end)

  tcp:connect(host, port, function(err)
    if done then return end
    done = true
    pcall(timer.stop, timer); pcall(timer.close, timer)
    pcall(tcp.close, tcp)
    cb(err == nil)
  end)
end

local LLAMA = {
  host = "127.0.0.1",
  port = 10000,
  args = { "-hf", "sweepai/sweep-next-edit-1.5B:latest", "--port", "10000" },
  logfile = vim.fn.stdpath("state") .. "/llama-server.log",
  handle = nil,
  started_by_nvim = false,
}

local function ensure_llama_running()
  if vim.fn.executable("llama-server") ~= 1 then
    notify("llama-server not found in PATH (skipping auto-start).", vim.log.levels.WARN)
    return
  end

  is_listening(LLAMA.host, LLAMA.port, 150, function(ok)
    if ok then return end

    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    local fd = uv.fs_open(LLAMA.logfile, "a", 420)

    local function pump(pipe, prefix)
      uv.read_start(pipe, function(err, data)
        if err or not data then return end
        if fd then uv.fs_write(fd, ("[%s] %s"):format(prefix, data)) end
      end)
    end
    pump(stdout, "stdout")
    pump(stderr, "stderr")

    local handle = uv.spawn("llama-server", {
      args = LLAMA.args,
      stdio = { nil, stdout, stderr },
      detached = false,
    }, function()
      if fd then uv.fs_close(fd) end
      if handle then pcall(handle.close, handle) end
      LLAMA.handle = nil
      LLAMA.started_by_nvim = false
    end)

    if not handle then
      notify("Failed to start llama-server.", vim.log.levels.ERROR)
      return
    end

    LLAMA.handle = handle
    LLAMA.started_by_nvim = true
    notify("Started llama-server on port 10000")
  end)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if LLAMA.started_by_nvim and LLAMA.handle then
      pcall(LLAMA.handle.kill, LLAMA.handle, "sigterm")
      vim.defer_fn(function()
        if LLAMA.handle then
          pcall(LLAMA.handle.kill, LLAMA.handle, "sigkill")
        end
      end, 800)
    end
  end,
})

-- ---------------------------------------------------------------------------
-- Bring it all together
-- ---------------------------------------------------------------------------

if not ensure_cursortab_present() then
  return
end

ensure_cursortab_server_built()
ensure_llama_running()

local ok, cursortab = pcall(require, "cursortab")
if not ok then
  vim.notify("Failed to require('cursortab')", vim.log.levels.ERROR)
  return
end

cursortab.setup({
  provider = "sweep",
  provider_url = "http://localhost:10000",
  provider_model = "sweep-next-edit-1.5b",
  provider_temperature = 0.0,
  provider_max_tokens = 100,
})
