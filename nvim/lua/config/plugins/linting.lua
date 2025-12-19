local lint = require("lint")
local project = require("config.project")

local use_dmypy = (vim.fn.executable("dmypy") == 1)

-- Wrap mypy linter to use dmypy daemon (faster)
if lint.linters.mypy and not lint.linters.dmypy then
    local mypy = lint.linters.mypy
    lint.linters.dmypy = vim.tbl_deep_extend("force", {}, mypy, {
        cmd = "dmypy",
        args = vim.list_extend({ "run", "--" }, vim.deepcopy(mypy.args or {})),
    })
end

lint.linters_by_ft = {
    python = { use_dmypy and "dmypy" or "mypy" },
}

-- Run from repo root so config + imports resolve correctly
if lint.linters.mypy then
    lint.linters.mypy.cwd = function()
        return project.project_root(0)
    end
end
if lint.linters.dmypy then
    lint.linters.dmypy.cwd = function()
        return project.project_root(0)
    end
end

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.py",
    callback = function(args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        if file:find("/%.venv/") then
            return
        end
        lint.try_lint()
    end,
})

vim.keymap.set("n", "<leader>tt", function()
    lint.try_lint({ use_dmypy and "dmypy" or "mypy" })
end, { desc = "Typecheck now (dmypy/mypy)" })
