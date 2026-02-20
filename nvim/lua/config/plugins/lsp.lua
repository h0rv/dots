-- Resolve a binary from the nearest .venv, falling back to PATH
local function venv_bin(name, bufnr)
    bufnr = bufnr or 0
    local buf = vim.api.nvim_buf_get_name(bufnr)
    local dir = buf ~= "" and vim.fs.dirname(buf) or vim.uv.cwd()
    local venv = vim.fs.find(".venv", { path = dir, upward = true, type = "directory" })[1]
    if venv then
        local bin = venv .. "/bin/" .. name
        if vim.uv.fs_stat(bin) then return bin end
    end
    return name
end

-- Python stack: basedpyright (types/navigation) + ruff (lint/format)
-- Note: project.lua activates .venv/bin on PATH at startup, so bare
-- commands like "ruff" and "basedpyright-langserver" resolve from venv.
vim.lsp.config("basedpyright", {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyrightconfig.json", "pyproject.toml", ".venv", ".git" },
    settings = {
        basedpyright = {
            disableOrganizeImports = true,
            analysis = {
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "standard",
                useLibraryCodeForTypes = true,
            },
        },
    },
    on_init = function(client)
        -- Point at venv python for import resolution
        client.config.settings.python = { pythonPath = venv_bin("python") }
        client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end,
})

vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", ".venv", ".git" },
})

-- TypeScript/JavaScript/React: typescript-language-server
vim.lsp.config("typescript", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
            suggest = {
                autoImports = true,
            },
        },
        javascript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
            suggest = {
                autoImports = true,
            },
        },
    },
})

vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".git" },
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    vim.fn.stdpath("config"),
                    vim.fn.stdpath("data"),
                },
                checkThirdParty = false,
            },
            completion = { callSnippet = "Replace" },
            hint = { enable = true },
        },
    },
})

vim.lsp.config("jsonls", {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git" },
    settings = {
        json = {
            validate = { enable = true },
            format = { enable = true },
        },
    },
})

vim.lsp.config("yamlls", {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yml" },
    root_markers = { ".git" },
    settings = {
        yaml = {
            validate = { enable = true },
            format = { enable = true },
            hover = true,
            completion = true,
        },
    },
})

vim.lsp.config("taplo", {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { ".git" },
})

vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
            },
            checkOnSave = true,
            check = { command = "clippy" },
            procMacro = { enable = true },
            formatting = { enable = true },
            inlayHints = {
                bindingModeHints = { enable = true },
                chainingHints = { enable = true },
                closureReturnTypeHints = { enable = "always" },
                lifetimeElisionHints = { enable = "always", useParameterNames = true },
                parameterHints = { enable = true },
                reborrowHints = { enable = "always" },
                typeHints = { enable = true },
            },
        },
    },
})

vim.lsp.config("elixirls", {
    cmd = { "elixir-ls" },
    filetypes = { "elixir", "heex" },
    root_markers = { "mix.exs", ".git" },
    settings = {
        elixirLS = {
            dialyzerEnabled = true,
            fetchDeps = false,
            enableTestLenses = true,
            suggestSpecs = true,
        },
    },
})

vim.lsp.enable({ "basedpyright", "ruff", "typescript", "lua_ls", "jsonls", "yamlls", "taplo", "rust_analyzer", "elixirls" })

vim.diagnostic.config({
    underline = true,
    severity_sort = true,
    update_in_insert = false,
    virtual_text = { spacing = 2, prefix = "●" },
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        -- Ruff: disable hover (basedpyright handles it)
        if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end

        -- Built-in LSP completion (autotrigger handles typing + server trigger chars like ".")
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

        local opts = { buffer = bufnr, silent = true }

        -- Navigation (via snacks picker)
        vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, vim.tbl_extend("force", opts, { desc = "References" }))
        vim.keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, vim.tbl_extend("force", opts, { desc = "Implementation" }))
        vim.keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, vim.tbl_extend("force", opts, { desc = "Type definition" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))

        -- Diagnostics
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, vim.tbl_extend("force", opts, { desc = "Prev diagnostic" }))
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        vim.keymap.set("n", "<leader>dd", function() Snacks.picker.diagnostics() end, vim.tbl_extend("force", opts, { desc = "All diagnostics" }))
        vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, vim.tbl_extend("force", opts, { desc = "Diagnostics -> quickfix" }))

        -- Mouse goto def
        vim.keymap.set("n", "<C-LeftMouse>", function() vim.lsp.buf.definition() end, { desc = "Go to definition (Ctrl+Click)" })
        vim.keymap.set("n", "<2-LeftMouse>", vim.lsp.buf.definition, { desc = "Go to definition (double click)" })

        pcall(function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end)
    end,
})

-- Completion / snippet keymaps
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then return "<C-n>" end
    if vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
        return ""
    end
    return "<Tab>"
end, { expr = true, silent = true })

vim.keymap.set("i", "<S-Tab>", function()
    if vim.fn.pumvisible() == 1 then return "<C-p>" end
    if vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
        return ""
    end
    return "<S-Tab>"
end, { expr = true, silent = true })

vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then return "<C-y>" end
    return "<CR>"
end, { expr = true, silent = true })

vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { silent = true })
