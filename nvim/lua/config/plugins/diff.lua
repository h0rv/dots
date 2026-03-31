vim.opt.diffopt:append({
    "algorithm:histogram",
    "linematch:60",
    "indent-heuristic",
})

require("diffview").setup({
    watch_index = true,
})

local function repo_root()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        path = vim.fn.getcwd()
    end

    return vim.fs.root(path, { ".git" }) or vim.fn.getcwd()
end

local function git(args)
    local cmd = { "git", "-C", repo_root() }
    vim.list_extend(cmd, args)

    local output = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
        return nil
    end

    return output
end

local function resolve_ref(candidates)
    for _, ref in ipairs(candidates) do
        if git({ "rev-parse", "--verify", ref }) then
            return ref
        end
    end

    return nil
end

local function resolve_main_ref()
    return resolve_ref({ "main", "origin/main", "master", "origin/master" })
end

local function detect_base_ref()
    local remote_head = git({ "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })
    if remote_head and remote_head[1] and remote_head[1] ~= "" then
        return remote_head[1]
    end

    return resolve_main_ref()
end

local function resolve_review_target(base_ref)
    if not base_ref or base_ref == "" then
        return detect_base_ref()
    end

    if base_ref == "main" or base_ref == "master" then
        return resolve_main_ref() or base_ref
    end

    return base_ref
end

local function review_revspec(base_ref)
    local target = resolve_review_target(base_ref)
    if not target then
        vim.notify("Could not determine base branch for PR review", vim.log.levels.ERROR)
        return nil
    end

    return target .. "...HEAD"
end

local function open_pr_review(base_ref)
    local revspec = review_revspec(base_ref)
    if not revspec then
        return
    end

    vim.cmd({ cmd = "DiffviewOpen", args = { revspec } })
end

local function close_review()
    if pcall(vim.cmd, "DiffviewClose") then
        return
    end

    if vim.bo.buftype == "terminal" then
        vim.cmd("tabclose")
        return
    end

    pcall(vim.cmd, "close")
end

local function open_pr_review_difftastic(base_ref)
    if vim.fn.executable("difft") ~= 1 then
        vim.notify("difftastic is not installed (missing 'difft' binary)", vim.log.levels.ERROR)
        return
    end

    local revspec = review_revspec(base_ref)
    if not revspec then
        return
    end

    vim.cmd("tabnew")
    vim.bo.buflisted = false
    vim.bo.filetype = "diff"
    local bufnr = vim.api.nvim_get_current_buf()

    vim.fn.termopen({
        "git",
        "--no-pager",
        "-C",
        repo_root(),
        "-c",
        "diff.external=difft",
        "diff",
        revspec,
    })

    vim.keymap.set("n", "q", close_review, { buffer = bufnr, silent = true, desc = "Close review" })
    vim.keymap.set("t", "q", [[<C-\><C-n><cmd>PRReviewClose<cr>]], { buffer = bufnr, silent = true, desc = "Close review" })
end

vim.api.nvim_create_user_command("PRReview", function(opts)
    open_pr_review(opts.args ~= "" and opts.args or nil)
end, {
    nargs = "?",
    desc = "Review current branch like a GitHub PR",
})

vim.api.nvim_create_user_command("PRReviewDifftastic", function(opts)
    open_pr_review_difftastic(opts.args ~= "" and opts.args or nil)
end, {
    nargs = "?",
    desc = "Review current branch with difftastic",
})

vim.api.nvim_create_user_command("PRReviewClose", close_review, {
    desc = "Close diff/review",
})

vim.api.nvim_create_user_command("PRReviewFiles", function()
    vim.cmd("DiffviewToggleFiles")
end, { desc = "Toggle PR review file list" })

vim.api.nvim_create_user_command("PRReviewRefresh", function()
    vim.cmd("DiffviewRefresh")
end, { desc = "Refresh PR review" })

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diff open" })
vim.keymap.set("n", "<leader>gm", function()
    open_pr_review(resolve_main_ref())
end, { desc = "Review vs main" })
vim.keymap.set("n", "<leader>gp", open_pr_review, { desc = "Review PR" })
vim.keymap.set("n", "<leader>gt", open_pr_review_difftastic, { desc = "Review PR (difftastic)" })
vim.keymap.set("n", "<leader>gf", "<cmd>PRReviewFiles<cr>", { desc = "Review files" })
vim.keymap.set("n", "<leader>gr", "<cmd>PRReviewRefresh<cr>", { desc = "Review refresh" })
vim.keymap.set("n", "<leader>gc", "<cmd>PRReviewClose<cr>", { desc = "Close diff/review" })
