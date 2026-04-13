local project = require("config.project")

local function python_root_dir_with(executable, blockers)
    return function(bufnr, on_dir)
        for _, blocker in ipairs(blockers or {}) do
            if project.local_executable(blocker, bufnr) then
                on_dir(nil)
                return
            end
        end

        if project.local_executable(executable, bufnr) then
            on_dir(project.project_root(bufnr))
            return
        end

        on_dir(nil)
    end
end

local function python_server(binary, ...)
    local args = { ... }

    return function(dispatchers, config)
        local command = project.local_executable(binary, config.root_dir) or
        project.resolve_executable(binary, config.root_dir)

        return vim.lsp.rpc.start(
            vim.list_extend({ command }, vim.deepcopy(args)),
            dispatchers,
            {
                cwd = config.root_dir,
                env = project.command_env(config.root_dir),
                detached = config.detached,
            }
        )
    end
end

-- Python stack: basedpyright (types/navigation) + ruff (lint/format)
-- Each server resolves its executable and env from the current workspace.
vim.lsp.config("basedpyright", {
    cmd = python_server("basedpyright-langserver", "--stdio"),
    filetypes = { "python" },
    root_dir = python_root_dir_with("basedpyright-langserver"),
    settings = {
        basedpyright = {
            disableOrganizeImports = true,
            analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "standard",
                useLibraryCodeForTypes = true,
            },
        },
    },
    before_init = function(_, config)
        local settings = {
            python = {
                pythonPath = project.python_path(config.root_dir),
            },
            basedpyright = {
                analysis = {
                    autoImportCompletions = true,
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    typeCheckingMode = "standard",
                    useLibraryCodeForTypes = true,
                },
            },
        }

        local config_path = project.basedpyright_config_path(config.root_dir)
        if config_path then
            settings.basedpyright.analysis.configFilePath = config_path
        end

        config.settings = vim.tbl_deep_extend("force", config.settings or {}, settings)
    end,
})

vim.lsp.config("ty", {
    cmd = python_server("ty", "server"),
    filetypes = { "python" },
    root_dir = python_root_dir_with("ty", { "basedpyright-langserver" }),
    settings = {
        ty = {},
    },
})

vim.lsp.config("pyright", {
    cmd = python_server("pyright-langserver", "--stdio"),
    filetypes = { "python" },
    root_dir = python_root_dir_with("pyright-langserver", { "basedpyright-langserver", "ty" }),
    settings = {
        python = {
            analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "standard",
                useLibraryCodeForTypes = true,
            },
        },
    },
    before_init = function(_, config)
        config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            python = {
                pythonPath = project.python_path(config.root_dir),
            },
        })
    end,
})

vim.lsp.config("ruff", {
    cmd = python_server("ruff", "server"),
    filetypes = { "python" },
    root_dir = function(bufnr, on_dir)
        if project.local_executable("ruff", bufnr) then
            on_dir(project.project_root(bufnr))
            return
        end

        on_dir(nil)
    end,
    init_options = {
        settings = {
            configurationPreference = "filesystemFirst",
        },
    },
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

vim.lsp.config("racket_langserver", {
    cmd = { "racket", "--lib", "racket-langserver" },
    filetypes = { "scheme", "racket" },
    root_markers = { ".git" },
})

vim.lsp.enable({ "basedpyright", "ty", "pyright", "ruff", "typescript", "lua_ls", "jsonls", "yamlls", "taplo",
    "rust_analyzer", "elixirls" })

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
        vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end,
            vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end,
            vim.tbl_extend("force", opts, { desc = "References" }))
        vim.keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end,
            vim.tbl_extend("force", opts, { desc = "Implementation" }))
        vim.keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end,
            vim.tbl_extend("force", opts, { desc = "Type definition" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, { desc = "Code action" }))

        -- Diagnostics
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end,
            vim.tbl_extend("force", opts, { desc = "Prev diagnostic" }))
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end,
            vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        vim.keymap.set("n", "<leader>dd", function() Snacks.picker.diagnostics() end,
            vim.tbl_extend("force", opts, { desc = "All diagnostics" }))
        vim.keymap.set("n", "<leader>de", function()
            vim.diagnostic.open_float(nil, { scope = "line", border = "rounded" })
        end, vim.tbl_extend("force", opts, { desc = "Line diagnostic" }))
        vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist,
            vim.tbl_extend("force", opts, { desc = "Diagnostics -> quickfix" }))

        -- Mouse goto def
        vim.keymap.set("n", "<C-LeftMouse>", function() vim.lsp.buf.definition() end,
            { desc = "Go to definition (Ctrl+Click)" })
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
